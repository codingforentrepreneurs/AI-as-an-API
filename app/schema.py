from pydantic import BaseModel

class Query(BaseModel):
    q: str