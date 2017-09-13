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
        "six"
    ],
    extras_require={
        'PFA':  ["titus >= 0.8.4-post"],
        'pandas': ["pandas >= 0.19.0"]
    },
    test_suite="test",
    tests_require=[
        "iso8601>=0.1.11",
        "PyYAML>=3.11",
        "requests>=2.11.1",
        "tabulate>=0.7.5",
        "websocket-client>=0.37.0",
        "avro >= 1.7.6",
        "six",
        "numpy >= 1.6.1",
        "pandas >= 0.19.0"
    ]
)
