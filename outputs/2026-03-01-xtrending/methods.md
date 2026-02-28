# Methods: Data Collection & Verification

## Overview

This document describes the methodology for collecting and verifying X (Twitter) trending cryptocurrency data for daily reports.

---

## Data Collection Pipeline

### Phase 1: X/Twitter Data Collection

**Primary Method: X API v2**
```bash
# Search recent crypto tweets (requires bearer token)
curl -X GET "https://api.twitter.com/2/tweets/search/recent?query=crypto%20trending&max_results=100" \
  -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"
```

**Fallback Method: Nitter Instances**
- Nitter is a privacy-focused alternative X frontend
- Instances: `nitter.net`, `nitter.moomoo.me`, `nitter.privacy.com.br`
- Access pattern: `https://nitter.net/<username>`

**Alternative: X Syndication API**
```bash
# Fetch individual tweet by ID (public endpoint)
curl "https://cdn.syndication.twimg.com/tweet-result?id=<TWEET_ID>&lang=en"
```

### Phase 2: Crypto Market Data Verification

**Sources Cross-Referenced:**
1. CryptoSlate (https://cryptoslate.com/coins/)
2. Decrypt (https://decrypt.co/)
3. CryptoNews (https://cryptonews.com/)
4. CoinTelegraph (https://cointelegraph.com/)

**Data Points Collected:**
- Current price (USD)
- 24h change (%)
- 7d change (%)
- 30d change (%)
- Market cap
- 24h trading volume

### Phase 3: Trending Topic Identification

**Criteria for "Trending":**
1. **Volume:** High mention count on X in 24h window
2. **Engagement:** Significant likes/retweets/replies
3. **News Correlation:** Covered by multiple crypto news outlets
4. **Price Movement:** Notable price action (>5% 24h or >20% 30d)
5. **Community Activity:** Active discussion in crypto communities

---

## Verification Process

### Step 1: Source Validation
- [ ] Verify each data source is accessible (HTTP 200)
- [ ] Check data freshness (timestamp within 24h)
- [ ] Cross-reference prices across 2+ sources

### Step 2: X Post Verification
For each X post included:
- [ ] Confirm URL format: `x.com/<user>/status/<id>`
- [ ] Verify post exists and is publicly accessible
- [ ] Record engagement metrics (likes, retweets, replies)
- [ ] Capture timestamp of post

### Step 3: Data Integrity
- [ ] All prices match across sources (±1% tolerance)
- [ ] Timestamps are consistent (same collection window)
- [ ] JSON data validates against schema
- [ ] No placeholder or test data in final report

---

## Collection Tools Used

| Tool | Purpose | Status |
|------|---------|--------|
| `web_fetch` | Fetch public crypto data | ✅ Working |
| `web_search` | Search indexed X content | ⚠️ Requires API key |
| `browser` | Direct X navigation | ⚠️ Requires browser service |
| X API v2 | Official tweet search | ⚠️ Requires auth token |
| Nitter | Alternative X frontend | ⚠️ Instance availability varies |

---

## Current Session Collection (2026-02-28)

**Successfully Collected:**
- ✅ CryptoSlate market data (15+ coins)
- ✅ Decrypt news headlines
- ✅ CryptoNews trending stories
- ✅ CoinTelegraph editorial content

**Limitations Encountered:**
- ⚠️ X/Twitter direct access blocked (requires authentication)
- ⚠️ web_search unavailable (Brave API key not configured)
- ⚠️ Browser service unavailable (timed out)

**Workaround Applied:**
- Aggregated trending topics from crypto news coverage
- Cross-referenced market data from multiple sources
- Documented methodology for future X post collection

---

## Recommended Setup for Full X Integration

### 1. Configure X API Access
```bash
# Set environment variables
export TWITTER_BEARER_TOKEN="your_bearer_token"
export TWITTER_API_KEY="your_api_key"
```

### 2. Configure OpenClaw Web Search
```bash
openclaw configure --section web
# Set BRAVE_API_KEY for web_search tool
```

### 3. Ensure Browser Service
```bash
# Check browser service status
openclaw browser status
# Restart if needed
openclaw gateway restart
```

---

## Data Schema

### Trending Topic Object
```json
{
  "rank": "number",
  "topic": "string",
  "summary": "string",
  "asset": "string",
  "price": "number",
  "change24h": "number",
  "change7d": "number",
  "change30d": "number",
  "marketCap": "string",
  "volume24h": "string",
  "source": "string",
  "sourceUrl": "string (URL)",
  "xDiscussion": "string",
  "sentiment": "string",
  "evidence": {
    "priceVerified": "boolean",
    "marketCapVerified": "boolean",
    "collectionTime": "ISO8601 timestamp"
  }
}
```

---

## Quality Assurance Checklist

Before publishing:
- [ ] All 5 trending topics have verified price data
- [ ] Each topic has source URL for verification
- [ ] News headlines have working links
- [ ] JSON data is valid and complete
- [ ] README matches data.json content
- [ ] Collection timestamp is recorded
- [ ] Limitations are documented transparently

---

## Contact & Attribution

- **Repository:** github.com/Dalomeve/xtrending-20260301
- **Data Sources:** CryptoSlate, Decrypt, CryptoNews, CoinTelegraph
- **License:** MIT
