# coding: utf-8

"""
    FastScore API (proxy)

    No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)

    OpenAPI spec version: 1.7
    
    Generated by: https://github.com/swagger-api/swagger-codegen.git
"""


from pprint import pformat
from six import iteritems
import re


class JetInfo(object):
    """
    NOTE: This class is auto generated by the swagger code generator program.
    Do not edit the class manually.
    """


    """
    Attributes:
      swagger_types (dict): The key is attribute name
                            and the value is attribute type.
      attribute_map (dict): The key is attribute name
                            and the value is json key in definition.
    """
    swagger_types = {
        'pid': 'int',
        'sandbox': 'str'
    }

    attribute_map = {
        'pid': 'pid',
        'sandbox': 'sandbox'
    }

    def __init__(self, pid=None, sandbox=None):
        """
        JetInfo - a model defined in Swagger
        """

        self._pid = None
        self._sandbox = None

        if pid is not None:
          self.pid = pid
        if sandbox is not None:
          self.sandbox = sandbox

    @property
    def pid(self):
        """
        Gets the pid of this JetInfo.

        :return: The pid of this JetInfo.
        :rtype: int
        """
        return self._pid

    @pid.setter
    def pid(self, pid):
        """
        Sets the pid of this JetInfo.

        :param pid: The pid of this JetInfo.
        :type: int
        """

        self._pid = pid

    @property
    def sandbox(self):
        """
        Gets the sandbox of this JetInfo.

        :return: The sandbox of this JetInfo.
        :rtype: str
        """
        return self._sandbox

    @sandbox.setter
    def sandbox(self, sandbox):
        """
        Sets the sandbox of this JetInfo.

        :param sandbox: The sandbox of this JetInfo.
        :type: str
        """

        self._sandbox = sandbox

    def to_dict(self):
        """
        Returns the model properties as a dict
        """
        result = {}

        for attr, _ in iteritems(self.swagger_types):
            value = getattr(self, attr)
            if isinstance(value, list):
                result[attr] = list(map(
                    lambda x: x.to_dict() if hasattr(x, "to_dict") else x,
                    value
                ))
            elif hasattr(value, "to_dict"):
                result[attr] = value.to_dict()
            elif isinstance(value, dict):
                result[attr] = dict(map(
                    lambda item: (item[0], item[1].to_dict())
                    if hasattr(item[1], "to_dict") else item,
                    value.items()
                ))
            else:
                result[attr] = value

        return result

    def to_str(self):
        """
        Returns the string representation of the model
        """
        return pformat(self.to_dict())

    def __repr__(self):
        """
        For `print` and `pprint`
        """
        return self.to_str()

    def __eq__(self, other):
        """
        Returns true if both objects are equal
        """
        if not isinstance(other, JetInfo):
            return False

        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """
        Returns true if both objects are not equal
        """
        return not self == other