import click
import pytest
import neoload_cli_lib.user_data as user_data
from helpers.test_utils import mock_login_get_urls


@pytest.mark.authentication
class TestUserData:
    def test_login(self, monkeypatch, request):
        mock_login_get_urls(monkeypatch)
        token = request.config.getoption('--token')
        api_url = request.config.getoption('--url')
        login = user_data.do_login(token, api_url, False)
        assert login.token == user_data.get_user_data().token
        assert login.url == user_data.get_user_data().url
        assert user_data.get_user_data().token == token
        assert user_data.get_user_data().url == api_url

    def test_login_no_write(self, monkeypatch, request):
        mock_login_get_urls(monkeypatch)
        token = request.config.getoption('--token')
        api_url = request.config.getoption('--url')
        login = user_data.do_login(token, api_url, True)
        assert login.token == user_data.get_user_data().token
        assert login.url == user_data.get_user_data().url
        assert user_data.get_user_data().token == token
        assert user_data.get_user_data().url == api_url

    def test_login_without_token(self):
        with pytest.raises(Exception) as context:
            user_data.do_login(None, 'some url', False)
        assert 'token is mandatory. please see neoload login --help.' in str(context.value)

    def test_logout(self, monkeypatch, request):
        mock_login_get_urls(monkeypatch)
        token = request.config.getoption('--token')
        api_url = request.config.getoption('--url')
        user_data.do_login(token, api_url, False)
        user_data.do_logout()
        with pytest.raises(click.ClickException) as context:
            user_data.get_user_data()
        assert 'You are\'nt logged. Please use command "neoload login" first' in str(context.value)
