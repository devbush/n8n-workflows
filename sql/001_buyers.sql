-- Run against the "onboarding" database as the "onboarding" role.
CREATE TABLE IF NOT EXISTS buyers (
  id                          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stripe_payment_intent_id    text NOT NULL UNIQUE,
  stripe_checkout_session_id  text,
  stripe_event_id             text NOT NULL,
  product_slug                text NOT NULL,
  email                       text NOT NULL,
  name                        text,
  amount_cents                integer NOT NULL,
  currency                    text NOT NULL,
  status                      text NOT NULL DEFAULT 'paid'
                              CHECK (status IN ('paid', 'refunded', 'disputed')),
  -- Only a SHA-256 of the claim token is stored; the plain token exists only in the email.
  claim_token_hash            text UNIQUE,
  discord_user_id             text,
  discord_username            text,
  claimed_at                  timestamptz,
  role_removed_at             timestamptz,
  reminder_sent_at            timestamptz,
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS buyers_unclaimed_idx
  ON buyers (created_at)
  WHERE claimed_at IS NULL AND status = 'paid';
