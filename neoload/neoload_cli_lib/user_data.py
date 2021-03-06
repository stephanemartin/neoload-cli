import os

import appdirs
import yaml

from neoload_cli_lib import rest_crud, cli_exception

__conf_name = "neoload-cli"
__version = "1.0"
__author = "neotys"
__config_dir = appdirs.user_data_dir(__conf_name, __author, __version)
__config_file = os.path.join(__config_dir, "config.yaml")
__yaml_schema_file = os.path.join(__config_dir, "yaml_schema.json")

__no_write = False


def do_logout():
    global __user_data_singleton
    __user_data_singleton = None
    if os.path.exists(__config_file):
        os.remove(__config_file)


def get_user_data(throw=True):
    if __user_data_singleton is None and throw:
        raise cli_exception.CliException("You are'nt logged. Please use command \"neoload login\" first")
    return __user_data_singleton


def do_login(token, url, no_write):
    global __no_write
    __no_write = no_write
    if token is None:
        raise cli_exception.CliException('token is mandatory. please see neoload login --help.')
    global __user_data_singleton
    __user_data_singleton = UserData.from_login(token, url)
    __compute_version_and_path()
    __save_user_data()
    return __user_data_singleton


def get_front_url_by_private_entrypoint():
    response = rest_crud.get('/nlweb/rest/rest-api/url-api/v1/action/get-front-end-url')
    return response['frontEndUrl']['rootUrl']


def __compute_version_and_path():
    file_storage = get_file_storage_from_swagger()
    front = get_front_url_by_private_entrypoint()
    __user_data_singleton.set_url(front, file_storage, None)


def get_file_storage_from_swagger():
    response = rest_crud.get_raw('explore/v2/swagger.yaml')
    spec = yaml.load(response.text, Loader=yaml.FullLoader)
    return spec['paths']['/tests/{testId}/project']['servers'][0]['url']


def get_nlweb_information():
    response = rest_crud.get_raw('v2/informations')
    if response.status_code == 200:
        json = response.json()
        __user_data_singleton.url(json['front_url'], json['filestorage_url'], json['version'])
        return True
    else:
        return False


class UserData:
    def __init__(self, token=None, url=None, desc=None):
        self.metadata = {}
        if desc:
            self.__dict__.update(desc)
        else:
            self.token = token
            self.url = url

    @staticmethod
    def from_dict(entries):
        return UserData(desc=entries)

    @staticmethod
    def from_login(token: str, url: str):
        return UserData(token, url)

    def __str__(self):
        token = '*' * (len(self.token) - 3) + self.token[-3:]
        metadata = ""
        for (key, value) in self.metadata.items():
            if value is not None:
                metadata += key + ": " + value + "\n"
        return "You are logged on " + self.url + " with token " + token + "\n\n" + metadata

    def get_url(self):
        return self.url

    def get_frontend_url(self):
        return self.metadata['frontend url']

    def get_token(self):
        return self.token

    def get_file_storage_url(self):
        return self.metadata['file storage url']

    def get_version(self):
        return self.metadata['version']

    def set_url(self, frontend, files_storage, version):
        if frontend:
            self.metadata['frontend url'] = frontend
        if files_storage:
            self.metadata['file storage url'] = files_storage
        if version:
            self.metadata['version'] = version
        else:
            self.metadata['version'] = 'legacy'


def __load_user_data():
    if os.path.exists(__config_file):
        with open(__config_file, "r") as stream:
            load = yaml.load(stream, Loader=yaml.BaseLoader)
            return UserData.from_dict(load)

    return None


__user_data_singleton = __load_user_data()


def __save_user_data():
    if not __no_write:
        os.makedirs(__config_dir, exist_ok=True)
        with open(__config_file, "w") as stream:
            yaml.dump(__user_data_singleton.__dict__, stream)


def set_meta(key, value):
    get_user_data().metadata[key] = value
    __save_user_data()


def get_meta(key):
    return get_user_data().metadata.get(key, None)


def get_meta_required(key):
    if key not in get_user_data().metadata:
        raise cli_exception.CliException('No name or id provided. Please specify the object name or id.')
    return get_user_data().metadata.get(key)


def __load_yaml_schema():
    if os.path.exists(__yaml_schema_file):
        with open(__yaml_schema_file, "r") as stream:
            return stream.read()
    return None


__yaml_schema_singleton = __load_yaml_schema()


def get_yaml_schema(throw=True):
    if __yaml_schema_singleton is None and throw:
        raise cli_exception.CliException("No yaml schema found. Please add --refresh option to download it first")
    return __yaml_schema_singleton


def update_schema(yaml_schema_as_json: str):
    global __yaml_schema_singleton
    __yaml_schema_singleton = yaml_schema_as_json
    os.makedirs(__config_dir, exist_ok=True)
    with open(__yaml_schema_file, "w") as stream:
        stream.write(__yaml_schema_singleton)
