# SMTP Setup Guide for Supabase Self-Hosted

This guide provides step-by-step instructions for configuring production-ready SMTP for your self-hosted Supabase deployment. SMTP is **required** for authentication features including:

- Email verification
- Password reset emails
- Magic link authentication
- User invitations

## Table of Contents

1. [Provider Options](#provider-options)
2. [AWS SES Setup (Recommended)](#aws-ses-setup-recommended)
3. [SendGrid Setup](#sendgrid-setup)
4. [Mailgun Setup](#mailgun-setup)
5. [Postmark Setup](#postmark-setup)
6. [Configuration](#configuration)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)

---

## Provider Options

| Provider | Free Tier | Paid Pricing | Best For | Setup Complexity |
|----------|-----------|--------------|----------|------------------|
| **AWS SES** | 62,000/month | $0.10/1K emails | High volume, AWS users | Medium |
| **SendGrid** | 100/day | $19.95/month (40K) | Small-medium apps | Easy |
| **Mailgun** | 5,000/month (3 months) | $35/month (50K) | Developer-friendly | Easy |
| **Postmark** | None | $15/month (10K) | Transactional emails | Easy |

### Recommendation

- **AWS SES**: Best cost-per-email for production workloads
- **SendGrid**: Easiest setup, good free tier for development
- **Postmark**: Best deliverability, simple pricing

---

## AWS SES Setup (Recommended)

### Prerequisites

- AWS account
- Domain verified in SES
- Production access enabled (requires request for new accounts)

### Step 1: Verify Domain

1. Open AWS SES Console: https://console.aws.amazon.com/ses/
2. Navigate to **Verified identities**
3. Click **Create identity**
4. Choose **Domain** and enter your domain
5. Select **Easy DKIM** (recommended)
6. Copy the CNAME records provided
7. Add records to your DNS:

```dns
# Example DNS records (from AWS SES)
<selector>._domainkey.yourdomain.com  CNAME  <value>.dkim.amazonses.com
```

8. Wait for verification (5-30 minutes)

### Step 2: Request Production Access

New AWS accounts start in "sandbox mode" (100 emails/day limit).

1. In SES Console, click **Account dashboard**
2. Click **Request production access**
3. Fill out the form:
   - **Mail type**: Transactional
   - **Website URL**: Your application URL
   - **Use case**: Authentication emails for AutoGPT Platform
   - **Bounce/complaint handling**: Describe your process
4. Submit request (usually approved within 24 hours)

### Step 3: Create SMTP Credentials

1. In SES Console, navigate to **SMTP settings**
2. Click **Create SMTP credentials**
3. Enter IAM user name (e.g., `supabase-smtp-user`)
4. Click **Create**
5. **IMPORTANT:** Download credentials immediately (shown only once)

Save the credentials:

```env
SMTP Username: AKIAIOSFODNN7EXAMPLE
SMTP Password: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Step 4: Configure Environment

Edit `/autogpt_platform/db/docker/.env`:

```bash
# AWS SES Configuration
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=AKIAIOSFODNN7EXAMPLE
SMTP_PASS=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
SMTP_SENDER_NAME="AutoGPT Platform"

# Enable TLS
ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
```

**Regional SMTP Endpoints:**

- `us-east-1`: email-smtp.us-east-1.amazonaws.com
- `us-west-2`: email-smtp.us-west-2.amazonaws.com
- `eu-west-1`: email-smtp.eu-west-1.amazonaws.com
- See [full list](https://docs.aws.amazon.com/ses/latest/dg/regions.html)

### Step 5: Restart Services

```bash
cd /path/to/autogpt_platform/db/docker
docker compose restart auth
```

---

## SendGrid Setup

### Step 1: Create Account

1. Sign up at https://sendgrid.com/
2. Verify your email address
3. Complete sender verification

### Step 2: Create API Key

1. Navigate to **Settings** → **API Keys**
2. Click **Create API Key**
3. Name: `supabase-smtp`
4. Permissions: **Full Access** (or **Mail Send** minimum)
5. Click **Create & View**
6. **IMPORTANT:** Copy the key immediately (shown only once)

### Step 3: Verify Domain (Optional but Recommended)

1. Navigate to **Settings** → **Sender Authentication**
2. Click **Verify a Single Sender** (quick) or **Authenticate Your Domain** (better deliverability)
3. Follow the verification steps

### Step 4: Configure Environment

Edit `/autogpt_platform/db/docker/.env`:

```bash
# SendGrid Configuration
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SMTP_SENDER_NAME="AutoGPT Platform"

ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
```

### Step 5: Restart Services

```bash
docker compose restart auth
```

---

## Mailgun Setup

### Step 1: Create Account

1. Sign up at https://www.mailgun.com/
2. Complete email verification
3. Add domain or use sandbox domain

### Step 2: Get SMTP Credentials

1. Navigate to **Sending** → **Domain Settings**
2. Select your domain
3. Click **SMTP credentials**
4. Note the credentials:

```env
SMTP Hostname: smtp.mailgun.org
Port: 587
Username: postmaster@<yourdomain>.mailgun.org
Password: <your-smtp-password>
```

### Step 3: Configure Environment

Edit `/autogpt_platform/db/docker/.env`:

```bash
# Mailgun Configuration
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=postmaster@yourdomain.mailgun.org
SMTP_PASS=your-smtp-password
SMTP_SENDER_NAME="AutoGPT Platform"

ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
```

### Step 4: Restart Services

```bash
docker compose restart auth
```

---

## Postmark Setup

### Step 1: Create Account

1. Sign up at https://postmarkapp.com/
2. Create a server (e.g., "AutoGPT Production")
3. Verify your domain

### Step 2: Get SMTP Credentials

1. In server settings, navigate to **Credentials**
2. Note the SMTP credentials:

```env
SMTP Server: smtp.postmarkapp.com
Port: 587 (or 2525)
Username: <your-server-token>
Password: <your-server-token>
```

### Step 3: Configure Environment

Edit `/autogpt_platform/db/docker/.env`:

```bash
# Postmark Configuration
SMTP_ADMIN_EMAIL=noreply@yourdomain.com
SMTP_HOST=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USER=your-server-token
SMTP_PASS=your-server-token
SMTP_SENDER_NAME="AutoGPT Platform"

ENABLE_EMAIL_SIGNUP=true
ENABLE_EMAIL_AUTOCONFIRM=false
```

### Step 4: Restart Services

```bash
docker compose restart auth
```

---

## Configuration

### Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `SMTP_ADMIN_EMAIL` | Sender email address | `noreply@yourdomain.com` |
| `SMTP_HOST` | SMTP server hostname | `smtp.sendgrid.net` |
| `SMTP_PORT` | SMTP server port | `587` (recommended) |
| `SMTP_USER` | SMTP username | API key or username |
| `SMTP_PASS` | SMTP password | API secret or password |
| `SMTP_SENDER_NAME` | Display name | `"AutoGPT Platform"` |
| `ENABLE_EMAIL_SIGNUP` | Allow email signups | `true` |
| `ENABLE_EMAIL_AUTOCONFIRM` | Skip email verification | `false` (production) |

### Port Options

- **Port 587**: STARTTLS (recommended)
- **Port 465**: SSL/TLS
- **Port 25**: Unencrypted (not recommended)
- **Port 2525**: Alternative to 587 (if blocked)

### Email Templates

Supabase uses customizable email templates. To customize:

1. Navigate to `docker-compose.yml`
2. Add volume mount for templates:

```yaml
services:
  auth:
    volumes:
      - ./email-templates:/email-templates:ro
    environment:
      GOTRUE_MAILER_TEMPLATES_CONFIRMATION: /email-templates/confirmation.html
      GOTRUE_MAILER_TEMPLATES_INVITE: /email-templates/invite.html
      GOTRUE_MAILER_TEMPLATES_RECOVERY: /email-templates/recovery.html
      GOTRUE_MAILER_TEMPLATES_MAGIC_LINK: /email-templates/magic_link.html
```

3. Create templates in `email-templates/` directory

**Template variables available:**

- `{{ .ConfirmationURL }}` - Confirmation link
- `{{ .Token }}` - OTP token
- `{{ .SiteURL }}` - Your site URL
- `{{ .Email }}` - User's email

---

## Testing

### Test Email Sending

```bash
# View auth service logs
docker compose logs auth -f

# Trigger a test email (password reset)
curl -X POST 'http://localhost:8000/auth/v1/recover' \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@yourdomain.com"
  }'
```

### Verify SMTP Connection

```bash
# Test SMTP connectivity
docker compose exec auth nc -zv $SMTP_HOST $SMTP_PORT

# Should output: Connection successful
```

### Check Delivery

1. Check provider dashboard for sent emails
2. Verify email arrives in inbox (check spam folder)
3. Verify links work correctly

---

## Troubleshooting

### Emails Not Sending

**Check auth service logs:**

```bash
docker compose logs auth | grep -i smtp
docker compose logs auth | grep -i mail
```

**Common errors:**

1. **"535 Authentication failed"**
   - Verify SMTP credentials are correct
   - For AWS SES, ensure SMTP password (not access key)
   - For SendGrid, ensure `SMTP_USER=apikey` exactly

2. **"Connection timeout"**
   - Verify SMTP host and port
   - Check firewall rules allow outbound connections on port 587
   - Try alternative port (2525)

3. **"554 Message rejected: Email address is not verified"**
   - AWS SES sandbox mode - verify recipient email or request production access
   - Verify sender domain in provider dashboard

### Emails in Spam

**Improve deliverability:**

1. **Configure SPF record:**

   ```dns
   TXT  @  v=spf1 include:_spf.yourdomain.com ~all
   ```

2. **Configure DKIM:**
   - Enable in provider dashboard
   - Add DKIM DNS records

3. **Configure DMARC:**

   ```dns
   TXT  _dmarc  v=DMARC1; p=none; rua=mailto:dmarc@yourdomain.com
   ```

### Template Rendering Issues

**Debug template variables:**

```bash
# Enable debug logging
docker compose exec auth \
  sh -c 'GOTRUE_LOG_LEVEL=debug /usr/local/bin/auth'
```

### Rate Limiting

**Provider limits:**

- AWS SES: 14 emails/second (default, can be increased)
- SendGrid: Varies by plan
- Mailgun: 100 emails/hour (free), unlimited (paid)
- Postmark: 1,000 emails/hour (default)

If hitting limits, implement queueing or upgrade plan.

---

## Security Best Practices

### Credential Management

1. **Never commit credentials to git**

   ```bash
   # Verify .env is in .gitignore
   grep -r "SMTP_PASS" .git/
   # Should return nothing
   ```

2. **Use environment-specific credentials**
   - Development: Use separate API keys
   - Staging: Use separate API keys
   - Production: Use separate API keys with strict permissions

3. **Rotate credentials regularly**
   - Create new API keys every 90 days
   - Revoke old keys after migration

### Email Security

1. **Enable DMARC/DKIM/SPF**
   - Prevents email spoofing
   - Improves deliverability

2. **Use HTTPS for all links**
   - Ensure `SITE_URL=https://yourdomain.com`

3. **Implement rate limiting**
   - Prevent abuse of password reset
   - Monitor for unusual sending patterns

---

## Monitoring

### Track Email Metrics

Most providers offer dashboards with:

- Delivery rate
- Bounce rate
- Spam complaints
- Open rate (if enabled)

### Set Up Alerts

Configure alerts for:

- High bounce rate (>5%)
- High spam complaint rate (>0.1%)
- SMTP connection failures
- Daily send volume anomalies

### Log Analysis

```bash
# Count emails sent in last hour
docker compose logs auth --since 1h | grep "email sent" | wc -l

# Find failed email attempts
docker compose logs auth | grep -i "failed to send"

# Monitor auth service health
docker compose exec auth curl localhost:9999/health
```

---

## Additional Resources

- [Supabase Email Configuration](https://supabase.com/docs/guides/self-hosting/docker#configuring-an-email-server)
- [AWS SES Documentation](https://docs.aws.amazon.com/ses/)
- [SendGrid Documentation](https://docs.sendgrid.com/)
- [Mailgun Documentation](https://documentation.mailgun.com/)
- [Postmark Documentation](https://postmarkapp.com/developer)
- [Email Authentication Best Practices](https://www.cloudflare.com/learning/email-security/dmarc-dkim-spf/)

---

## Summary

You have now configured production SMTP for your self-hosted Supabase deployment. Key outcomes:

✅ Production SMTP provider configured
✅ Email authentication enabled
✅ Sender domain verified
✅ Email templates available for customization

**Next Steps:**

1. Test all authentication flows (signup, password reset, magic links)
2. Configure email templates for branding
3. Set up email monitoring and alerts
4. Implement SPF/DKIM/DMARC for deliverability
5. Monitor bounce and complaint rates
