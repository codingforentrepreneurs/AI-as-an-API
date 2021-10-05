import uuid
from cassandra.cqlengine import columns
from cassandra.cqlengine.models import Model


class SMSInference(Model):
    __keyspace__ = "spam_inferences"
    uuid = columns.UUID(primary_key=True, default=uuid.uuid1) # uuid.uuid1 -> timestamp
    query = columns.Text()
    label = columns.Text()
    confidence = columns.Float()
    model_version = columns.Text(default='v1')