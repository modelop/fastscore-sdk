# these are just temporary wrappers for some of the CLI functionality
# ignore the insecure request warnings.
import requests
requests.packages.urllib3.disable_warnings()

from .connect import connect
from .model import add_model, get_model, remove_model, list_models
from .stream import add_stream, get_stream, remove_stream, list_streams
from .schema import add_schema, get_schema, remove_schema, list_schemata
from .job import run_job, job_input, stop_job, deploy_model, deploy_input_stream, deploy_output_stream
from .sensor import add_sensor, get_sensor, remove_sensor, list_sensors
from .attachment import list_attachments, add_attachment, get_attachment, remove_attachment
