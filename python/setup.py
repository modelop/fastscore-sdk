from setuptools import find_packages, setup
setup(
    name = "fastscore",
    description = "FastScore SDK",
    version = "dev",
    packages = find_packages(),
    use_2to3=True,
    author="Open Data Group",
    author_email="support@opendatagroup.com",
    install_requires = [
        "iso8601>=0.1.11",
        "PyYAML>=3.11",
        "requests>=2.11.1",
        "tabulate>=0.7.5",
        "websocket-client>=0.37.0",
        "avro >= 1.7.6",
        "six",
        "urllib3 >= 1.20",
        "certifi"
    ],
    test_suite="test",
    tests_require=[
        "mock >= 2.0.0",
        "iso8601>=0.1.11",
        "PyYAML>=3.11",
        "requests>=2.11.1",
        "tabulate>=0.7.5",
        "websocket-client>=0.37.0",
        "avro >= 1.7.6",
        "six"
    ]
)
