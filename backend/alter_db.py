from database import engine
from sqlalchemy import text

with engine.connect() as conn:
    conn.execute(text('ALTER TABLE relay_states ADD COLUMN IF NOT EXISTS schedule_time VARCHAR;'))
    conn.commit()
    print("Column added successfully")
