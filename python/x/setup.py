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
        "six",
        "certifi",
        "urllib3"
    ],
    test_suite="test",
    tests_require=[
        "six",
        "certifi",
        "urllib3"
    ]
)
