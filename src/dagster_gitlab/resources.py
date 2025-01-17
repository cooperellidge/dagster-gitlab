from typing import Any, overload

from dagster import ConfigurableResource, InitResourceContext, resource

from dagster_gitlab import GitlabClient, GitlabGraphQL, GitlabRest
from dagster_gitlab._utils.enums import ClientType
from dagster_gitlab._utils.warn import experimental_warning, wrap_warnings


class GitlabResource(ConfigurableResource):  # noqa: D101
    def __init__(  # noqa: PLR0913
        self,
        token: str,
        url: str,
        project_id: int | None,
        client_type: ClientType = ClientType.REST,
        *,
        ssl_verify: bool = True,
        ignore_experimental: bool = False,
    ) -> None:
        """A GitLab resource."""
        self._ignore_experimental = ignore_experimental

        with wrap_warnings(ignore=self._ignore_experimental):
            if client_type is ClientType.GRAPHQL:
                experimental_warning(obj=GitlabGraphQL)

        self._client_type = client_type

        # Client args
        self._token = token
        self._url = url
        self._project_id = project_id
        self._ssl_verify = ssl_verify

    # These overloads are used to says that kwargs are only allowed with a custom_client
    @overload
    def get_client(
        self,
    ) -> GitlabClient: ...
    @overload
    def get_client(
        self,
        custom_client: type[GitlabClient],
        **kwargs: Any,  # noqa: ANN401
    ) -> GitlabClient: ...
    def get_client(  # noqa: D102
        self,
        custom_client: type[GitlabClient] | None = None,
        **kwargs: Any,
    ) -> GitlabClient:
        kwargs = {
            "token": self._token,
            "url": self._url,
            "project_id": self._project_id,
            "ssl_verify": self._ssl_verify,
            **kwargs,
        }

        if custom_client is not None:
            return custom_client(**kwargs)

        match self._client_type:
            case ClientType.REST:
                return GitlabRest(**kwargs)
            case ClientType.GRAPHQL:
                with wrap_warnings(ignore=self._ignore_experimental):
                    return GitlabGraphQL(**kwargs)


@resource(config_schema=GitlabResource.to_config_schema(), description="GitLab client.")
def gitlab_resource(context: InitResourceContext) -> GitlabClient:  # noqa: D103
    return GitlabResource(**context.resource_config).get_client()
