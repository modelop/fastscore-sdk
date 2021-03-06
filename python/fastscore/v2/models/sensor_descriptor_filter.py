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


class SensorDescriptorFilter(object):
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
        'type': 'str',
        'threshold': 'float',
        'min_value': 'float',
        'max_value': 'float'
    }

    attribute_map = {
        'type': 'Type',
        'threshold': 'Threshold',
        'min_value': 'MinValue',
        'max_value': 'MaxValue'
    }

    def __init__(self, type=None, threshold=None, min_value=None, max_value=None):
        """
        SensorDescriptorFilter - a model defined in Swagger
        """

        self._type = None
        self._threshold = None
        self._min_value = None
        self._max_value = None

        if type is not None:
          self.type = type
        if threshold is not None:
          self.threshold = threshold
        if min_value is not None:
          self.min_value = min_value
        if max_value is not None:
          self.max_value = max_value

    @property
    def type(self):
        """
        Gets the type of this SensorDescriptorFilter.

        :return: The type of this SensorDescriptorFilter.
        :rtype: str
        """
        return self._type

    @type.setter
    def type(self, type):
        """
        Sets the type of this SensorDescriptorFilter.

        :param type: The type of this SensorDescriptorFilter.
        :type: str
        """

        self._type = type

    @property
    def threshold(self):
        """
        Gets the threshold of this SensorDescriptorFilter.

        :return: The threshold of this SensorDescriptorFilter.
        :rtype: float
        """
        return self._threshold

    @threshold.setter
    def threshold(self, threshold):
        """
        Sets the threshold of this SensorDescriptorFilter.

        :param threshold: The threshold of this SensorDescriptorFilter.
        :type: float
        """

        self._threshold = threshold

    @property
    def min_value(self):
        """
        Gets the min_value of this SensorDescriptorFilter.

        :return: The min_value of this SensorDescriptorFilter.
        :rtype: float
        """
        return self._min_value

    @min_value.setter
    def min_value(self, min_value):
        """
        Sets the min_value of this SensorDescriptorFilter.

        :param min_value: The min_value of this SensorDescriptorFilter.
        :type: float
        """

        self._min_value = min_value

    @property
    def max_value(self):
        """
        Gets the max_value of this SensorDescriptorFilter.

        :return: The max_value of this SensorDescriptorFilter.
        :rtype: float
        """
        return self._max_value

    @max_value.setter
    def max_value(self, max_value):
        """
        Sets the max_value of this SensorDescriptorFilter.

        :param max_value: The max_value of this SensorDescriptorFilter.
        :type: float
        """

        self._max_value = max_value

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
        if not isinstance(other, SensorDescriptorFilter):
            return False

        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """
        Returns true if both objects are not equal
        """
        return not self == other
