from dagster_gitlab import hello


def test_hello() -> None:
    assert hello() is not None
