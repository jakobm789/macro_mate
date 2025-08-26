# Credential Rotation Policy

This policy defines how database credentials and API keys are rotated and managed.

## Rotation Cycle

- Rotate all database passwords, connection strings, and external API keys every six months (January and July).
- Schedule reminders so the rotation is not missed.

## Service Accounts

- Use dedicated service accounts for automated access.
- Each service account should have the minimum permissions necessary for its task.
- Personal user accounts must not be used for database or API access.

## Rotation Process

1. **Inventory credentials**: List all database credentials and API keys in use.
2. **Generate new credentials**: Create replacements in the secret management system.
3. **Update applications**: Deploy configuration changes so services use the new credentials.
4. **Validate**: Confirm that services operate correctly with the new credentials.
5. **Revoke old credentials**: Remove or disable previous credentials after validation.
6. **Record and schedule**: Document the rotation in the team wiki with date and responsible person, and set the next reminder.

Copy this document into the team wiki so the process is easily accessible to all team members.
