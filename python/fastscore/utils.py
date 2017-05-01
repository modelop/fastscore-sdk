# utility functions
import json

def compare_items(obj1, obj2, f_error):
    """
    Compares two JSON objects. Float fields are considered equal if they
    are within a margin of error:
    abs(a - b)/(abs(a) + abs(b)) <= f_error

    Required fields:
    - obj1: The first object
    - obj2: The second object
    - f_error: A margin of error
    """
    if type(obj1) != type(obj2):
        print 'Type mismatch: ' + str(type(obj1)) + ' != ' + str(type(obj2))
        return False
    if type(obj1) is list:
        if len(obj1) != len(obj2):
            print 'Length mismatch: ' + str(len(obj1)) + ' != ' + str(len(obj2))
            return False
        length = len(obj1)
        for i in range(0, length):
            if compare_items(obj1[i], obj2[i], f_error) == False:
                return False
        return True
    if type(obj1) is dict:
        keys1 = sorted(obj1.keys())
        keys2 = sorted(obj2.keys())
        if keys1 != keys2:
            print 'Key mismatch'
            return False
        for key in keys1:
            if compare_items(obj1[key], obj2[key], f_error) == False:
                return False
        return True
    if type(obj1) is float:
        matches = compare_floats(float1, float2)
        if not matches:
            print 'Outside error margin'
        return matches
    return obj1 == obj2

def compare_floats(float1, float2, f_error=0.01, zero_tolerance=1e-8, inf_tolerance=1e80):
    if abs(float1) < zero_tolerance and abs(float2) < zero_tolerance:
        return True
    elif abs(float1) > inf_tolerance and abs(float2) > inf_tolerance \
       and float1/float2 > 0:
        return True
    elif 2*abs(float1 - float2)/(abs(float1) + abs(float2)) <= f_error:
        return True
    else:
        return False
