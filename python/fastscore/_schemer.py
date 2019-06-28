
import random
from itertools import groupby
from ordered_set import OrderedSet
from datetime import datetime
import re

MAX_INT   = 2147483647
MIN_INT   = -2147483648
MAX_LONG  = 9223372036854775807
MIN_LONG  = -9223372036854775808

MAX_FLOAT = 3.402823e+38
MIN_FLOAT = -3.402823e+38

SYMBOL_PATTERN = "^[a-zA-Z0-9_]*$"
UUID_PATTERN = "^([0-9a-f]{32}|[0-9a-f]{40})$]*$"

TEMP_TOP = '$$machia_'

def _infer(data, verbose=False, **kwargs):
    if verbose:
        print(("{} sample data item(s) provided".format(len(data))))

    rsets = extract_records(data, verbose, **kwargs)
    optional = optional_fields(data, rsets, verbose, **kwargs)
    rdefs = { TEMP_TOP: {'data': data} }
    optional[TEMP_TOP] = set()
    collect_field_data(rdefs, rsets, verbose, **kwargs)

    def maybe_optional(name, field):
        if field['name'] in optional[name]:
            field['default'] = default_value(field['type'])
        return field

    records = {
        name: {
            'type': 'record',
            'name': name,
            'fields': [
                maybe_optional(name, {
                    'name': f,
                    'type': infer_schema(data, **kwargs),
                }) for f,data in list(rec.items())
            ]
        } for name,rec in list(rdefs.items())
    }

    schema = records[TEMP_TOP]['fields'][0]['type']
    return expand_records(schema, records)

def expand_records(schema, records):
    expanded = []
    def explode(schema):
        if isinstance(schema, list):
            return [ explode(x) for x in schema ]
        if isinstance(schema, str) and schema in records and not schema in expanded:
            expanded.append(schema)
            schema = records[schema]
            for field in schema['fields']:
                field['type'] = explode(field['type'])
            return schema
        else:
            return schema
    return explode(schema)

def extract_records(data, verbose=False, quiet=False, records={}, **kwargs):
    count = 0
    namesets = []
    for f in fieldsets(data, **kwargs):
        count += 1
        if any([ f <= x for x in namesets ]):
            continue
        namesets = list([x for x in namesets if not x <= f])
        namesets.append(f)
    if verbose:
        print(("{} record instance(s) found".format(count)))
        print(("{} record type(s) detected".format(len(namesets))))
    
    ambiguous = []
    for name,fields in list(records.items()):
        if len([ f for f in namesets if set(fields) <= f ]) > 1:
            ambiguous.append(name)
    for name in ambiguous:
        if not quiet:
            print(("*** preconfigured record {} is ambiguous - ignored".format(name)))
        del records[name]

    rsets = {}
    for f in namesets:
        for name,fields in list(records.items()):
            if set(fields) <= f:
                assert not name in rsets
                if verbose:
                    print(("  {} = {}".format(name, ellipsis(64, ", ".join(f)))))
                rsets[name] = f
                break
        else:
            name = random_name("Rec")
            assert not name in rsets
            if verbose:
                print(("  {} (generated) = {}".format(name, ellipsis(64, ", ".join(f)))))
            rsets[name] = f
    return rsets

def optional_fields(data, rsets, verbose=False, **kwargs):
    optional = {name: set() for name in rsets}
    for f in fieldsets(data, **kwargs):
        for name,fields in list(rsets.items()):
            if f <= fields:
                missing = fields - f
                if len(missing) > 0 and verbose and False: # disabled
                    print(("An instance of {} with {} field(s) missing detected".\
                            format(name, ellipsis(32, ", ".join(missing)))))
                optional[name] |= missing
    return optional

def fieldsets(data, max_field_count=100, uuid_field_names=False, **kwargs):
    if isinstance(data, dict):
        names = OrderedSet(data.keys())
        # map or record
        if len(names) > 0 and len(names) <= max_field_count:
            if uuid_field_names or \
               not any([ re.match(UUID_PATTERN, name) for name in names ]):
                yield names
        for x in list(data.values()):
            for f in fieldsets(x, max_field_count, uuid_field_names, **kwargs):
                yield f
    elif isinstance(data, list):
        for x in data:
            for f in fieldsets(x, max_field_count, uuid_field_names, **kwargs):
                yield f

def collect_field_data(rdefs, rsets, verbose=False, **kwargs):
    todo = [TEMP_TOP]

    def nip(x):
        if not isinstance(x, dict):
            return x
        for name,fields in list(rsets.items()):
            if set(x.keys()) <= fields:
                if not name in rdefs:
                    rdefs[name] = {f: [] for f in fields}
                for f,v in list(x.items()):
                    rdefs[name][f].append(v)
                if not name in todo:
                    todo.append(name)
                return {'$record': name}
        return x

    while len(todo) > 0:
        rdef = rdefs[todo.pop()]
        for f in rdef:
            rdef[f] = list(map(nip, rdef[f]))

def random_name(prefix):
    return prefix + str(random.randint(0, 1000000))

def ellipsis(w, s):
    if len(s) <= w:
        return s
    else:
        return "{:{width}.{width}}...".format(s, width=w-3)

def infer_schema(data, **kwargs):
    def pre_type(x):
        if x == None:
            return 'null'
        elif isinstance(x, dict):
            if '$record' in x:
                return x['$record']
            return 'map'
        elif isinstance(x, list):
            return 'array'
        elif isinstance(x, bool):
            return 'boolean'
        elif isinstance(x, int):
            return 'int'
        elif isinstance(x, float):
            return 'float'
        elif isinstance(x, datetime):
            return 'date'
        else:
            assert isinstance(x, bytes) or isinstance(x, str)
            return 'str'
    groups = groupby(sorted(data, key=pre_type), key=pre_type)
    u = [ infer_uniform(x, list(y), **kwargs) for x,y in groups ]
    return u[0] if len(u) == 1 else u

def infer_uniform(tag, data, **kwargs):
    if tag == 'null':
        return "null"
    elif tag == 'int':
        schema = "int"
        for x in data:
            if x > MAX_INT or x < MIN_INT:
                schema = "long"
                if x > MAX_LONG or x < MIN_LONG:
                    raise ValueError("{} is out of range".format(x))
        return schema
    elif tag == 'float':
        schema = "float"
        for x in data:
            if x > MAX_FLOAT or x < MIN_FLOAT:
                schema = "double"
        return schema
    elif tag == 'boolean':
        return "boolean"
    elif tag == 'str':
        return infer_str(data, **kwargs)
    elif tag == 'date':
        return {
            'type': 'long',
            'logicalType': 'timestamp-millis'
        }
    elif tag == 'array':
        flat_data = [ x for arr in data for x in arr ]
        return {
            'type': 'array',
            'items': infer_schema(flat_data, **kwargs)
        }
    elif tag == 'map':
        values = []
        for x in data:
            values += list(x.values())
        return {
            'type': 'map',
            'values': infer_schema(values, **kwargs)
        }
    else:
        return tag

def infer_str(data, max_syms_count=10, max_syms_ratio=0.1, \
                    max_fixed_count=10, min_fixed_size=10, 
                    uuid_enum_symbols=False, enums={}, **kwargs):
    syms = set(data)
    if len(syms) > 1 and len(syms) <= max_syms_count and \
       len(syms) <= len(data) * max_syms_ratio and \
       all([ re.match(SYMBOL_PATTERN, x) for x in syms ]) and \
       (uuid_enum_symbols or 
            not any([ re.match(UUID_PATTERN, x) for x in syms])):
        # enum
        for name,symbols in list(enums.items()):
            if syms <= set(symbols):
                break
        else:
            name = random_name('Enum') 
        return {
            'type': 'enum',
            'name': name,
            'symbols': list(syms)
        }
    if len(data) >= max_fixed_count:
        sizes = set([ len(x) for x in data ])
        size = sizes.pop()
        if size >= min_fixed_size and len(sizes) == 0:
            # fixed
            name = random_name('Fixed')
            return {
                'type': 'fixed',
                'name': name,
                'size': size
            }
    return 'string'

def default_value(schema):
    if schema == "null":
        return None
    elif schema == "boolean":
        return False
    elif schema == "int":
        return 0
    elif schema == "long":
        return 0
    elif schema == "float":
        return 0.0
    elif schema == "double":
        return 0.0
    elif schema == "string":
        return ''
    elif schema == "bytes":
        return ''
    elif isinstance(schema, dict) and schema['type'] == 'array':
        return []
    elif isinstance(schema, dict) and schema['type'] == 'map':
        return {}
    elif isinstance(schema, list):
        for x in schema:
            try:
                return default_value(x)
            except:
                continue
        return None
    else:
        return None
