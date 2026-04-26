CREATE TABLE IF NOT EXISTS app_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  install_id TEXT NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_app_events_install_id ON app_events(install_id);
CREATE INDEX IF NOT EXISTS idx_app_events_event_type ON app_events(event_type);
CREATE INDEX IF NOT EXISTS idx_app_events_user_id ON app_events(user_id);

