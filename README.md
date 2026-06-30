# Exploring Cyberbullying Patterns in Twitter Data with BigQuery + Gemini

## What this project is

I wanted a hands-on way to get comfortable with SQL in BigQuery, but instead of running through generic tutorial exercises, I figured I'd learn faster by picking a real-ish dataset and asking real questions of it — the kind where I genuinely didn't know what the answer would be going in.

I'm still not strong at writing SQL from scratch, so this project doubled as practice in something I think is becoming its own skill: describing a question precisely in plain English, letting Gemini (BigQuery's built-in AI assistant) turn that into a SQL query, then reading the generated SQL closely enough to verify it's actually doing what I asked before trusting the output. A few times my first prompt produced a query that technically ran but didn't quite answer what I meant, so I'd refine the wording and try again. That loop — ask, generate, verify, refine — ended up being the most useful thing I practiced here, more than the SQL syntax itself.

**Getting the data:** I pulled a labeled cyberbullying dataset from Kaggle (~47,000 tweets, each tagged as one of six categories: `religion`, `age`, `gender`, `ethnicity`, `other_cyberbullying`, or `not_cyberbullying`, along with engagement metrics like likes, replies, and shares). I uploaded the CSV directly into BigQuery as a native table, which took a couple of tries to get right — I ran into a few early stumbles around table naming (originally had spaces in the table name, which BigQuery quietly tolerated but made every query need backticks) and around which Google Cloud project my dataset actually lived in versus the one I had open in the console. Cleaning that up was its own small lesson in how project/dataset/table scoping works in BigQuery.

Below is what I found, roughly in the order I investigated it.

---

## Starting point: how balanced is this dataset?

Before testing any real hypothesis, I wanted to know whether the categories were even comparable in size. If one category had 3x more tweets than another, any later comparison would be misleading.

| Category | Tweet Count |
|---|---|
| religion | 8,027 |
| age | 8,025 |
| gender | 8,013 |
| ethnicity | 7,988 |
| not_cyberbullying | 7,979 |
| other_cyberbullying | 7,860 |

Turns out it's nicely balanced — under 2% spread between the biggest and smallest group. Good, that means I can trust later comparisons aren't just an artifact of sample size.

---

## The question I actually cared about: does harmful content get more engagement?

This is the one I was most curious about going in. There's a lot of public conversation around how engagement-driven platforms might reward outrage or harmful content with more reach. I wanted to see if that showed up even in this simple, static dataset — no algorithm involved, just raw likes/replies/shares attached to each tweet.

**My hypothesis:** cyberbullying content gets more engagement than safe content.

First pass — averaging the raw metrics by category:

| Type | Avg Likes | Avg Replies | Avg Shares |
|---|---|---|---|
| not_cyberbullying | 258.3 | 49.1 | 148.9 |
| age | 257.1 | 49.2 | 149.7 |
| religion | 256.1 | 49.5 | 151.0 |
| gender | 252.3 | 48.7 | 151.0 |
| other_cyberbullying | 251.9 | 49.5 | 148.7 |
| ethnicity | 250.0 | 49.3 | 150.3 |

Honestly, this surprised me — the numbers are almost identical across every category. Likes range from 250 to 258, replies barely move from 49, shares sit around 150 no matter what. That's a flat result, which made me second-guess myself: did I query the wrong column, or is this genuinely no pattern?

So I re-ran it a second way, using the dataset's pre-built `engagement_score` (a composite of likes/replies/shares) instead of the individual metrics, just to cross-check:

| Type | Avg Engagement Score |
|---|---|
| religion | 456.6 |
| not_cyberbullying | 456.4 |
| age | 456.0 |
| gender | 451.9 |
| other_cyberbullying | 450.1 |
| ethnicity | 449.6 |

Same story. The spread here is about 1.5%, which is basically noise.

**So I'm rejecting my own hypothesis.** In this dataset, harmful content isn't getting disproportionately more engagement than safe content — at least not by these surface-level metrics. I think the honest caveat here is that this is a static, historical dataset with no actual recommendation algorithm behind it, so it can't tell us anything about *amplification* (whether a platform's feed ranking pushes harmful content to more people). It can only tell us that, once posted, people don't seem to engage with it meaningfully differently. That's a narrower claim than I started out wanting to make, but it's the honest one.

---

## Does the type of harm shift over time?

Once the engagement angle came up flat, I wanted a different lens — instead of "does harm get more attention," I asked "does the *kind* of harm change year to year." I excluded `not_cyberbullying` here since I only cared about competition between the actual harmful categories.

| Year | Top Harmful Type | Count |
|---|---|---|
| 2020 | religion | 2,041 |
| 2021 | religion | 2,007 |
| 2022 | ethnicity | 2,042 |
| 2023 | age | 2,041 |

This is more interesting than I expected. Religion-based content led for two straight years, then ethnicity took over in 2022, then age-based content (likely school/bullying-related) took the lead in 2023. The total volume of whichever category was "winning" stayed almost exactly the same each year (~2,000), but which category it was kept changing.

My read on this: the *amount* of harmful content people produce in a given year seems pretty stable, but *what they're arguing about* shifts — probably tracking whatever's dominating the news cycle or public discourse that year. If I were digging further, I'd want to cross-reference 2022 against major world events to see if the ethnicity spike lines up with something specific, rather than just noting the pattern exists.

One thing I noticed while running this query: the year column showed a `null` value for a small number of rows, which led me to check the data quality before trusting this table fully.

## Quick data quality check: those null dates

20 out of roughly 47,000 rows had a missing `date_posted`. That's 0.04% of the dataset, which is small enough that I almost skipped checking it — but I've learned that's exactly the kind of thing that's easy to wave away and later regret, so I pulled the actual rows to look.

No obvious pattern jumped out — the nulls were spread across `gender`, `age`, `ethnicity`, `other_cyberbullying`, and `not_cyberbullying`, not concentrated in one category. I did spot one exact duplicate pair in there, which makes me suspect this is a minor data collection or upload glitch rather than anything systemic in how tweets were labeled.

Given how small the number is, I don't think it changes anything about the year-over-year finding above — but I wanted to actually verify that instead of just assuming it.

---

## The finding I'm most proud of: tweet length by category

After the flat engagement results, I went looking for something — anything — that actually showed real separation between categories. Tweet length turned out to be it, and it wasn't even my first idea; I tried it almost as an afterthought.

| Type | Avg Tweet Length (characters) |
|---|---|
| religion | 197.9 |
| age | 173.5 |
| ethnicity | 139.3 |
| gender | 136.5 |
| other_cyberbullying | 85.8 |
| not_cyberbullying | 83.2 |

This one actually has a real, visible pattern — religion-based tweets are nearly **2.4x longer** than safe content (198 vs 83 characters), and age-based content isn't far behind. Meanwhile ethnicity and gender sit in the middle, and safe/other content stays short.

Thinking about why: religion and age-based harmful content reads more like an argument — people quoting scripture, making historical claims, building a case across a few sentences. Ethnicity and gender-based harmful content, from skimming a sample of the raw tweets earlier in this project, leaned more toward short slurs and direct insults — get the point across in a few words and move on.

If you were trying to detect this kind of content automatically, that distinction matters: a keyword/slur-filter is probably good enough to catch a lot of the short ethnicity/gender content, but the longer religion/age-based content would slip past keyword filters since it reads like ordinary debate on the surface — that's the kind of thing a more context-aware approach would need to catch.

## One more angle: does location tell us anything?

Finally, I checked whether `user_location` (a free-text field users fill in on their profile) showed any geographic concentration.

| Location | Top Type | Count |
|---|---|---|
| India | religion | 1,634 |
| USA | not_cyberbullying / gender | 1,199 |
| Brazil | ethnicity | 846 |
| Canada | not_cyberbullying | 842 |
| UK | religion | 833 |
| Australia | gender | 829 |

India and the USA dominate by raw volume, which I'd guess just reflects where this platform has the most users rather than anything behavioral. Within each country, no single category stood out by more than about 5% — so there's no strong "this country skews toward this type of harm" story here.

I want to be upfront about the limits of this one: location is self-reported, plenty of rows are blank (I'd seen that earlier when first scanning the table), and people sometimes put joke answers in profile fields. So I'm treating this as a soft, directional signal at best — not something I'd put much weight behind in a real investigation without better location data.

---

## What I'd take away from this

If I had to summarize what I actually learned, not just what the tables say:

- My starting hypothesis (harmful content gets more engagement) didn't hold up, and I checked it twice before believing that. Good reminder that a clean, confident hypothesis can still be wrong, and that's a fine outcome as long as you test it properly instead of forcing a story onto flat data.
- The *kind* of harmful content people post about shifts year to year, even if the overall volume stays steady.
- Tweet length ended up being the most informative signal in the whole dataset, which I did not expect going in. It's a good reminder that the obvious metric (engagement) isn't always where the real pattern lives.
- I deliberately stopped to check data quality (the null dates) even though it was a tiny number of rows, because I think that habit matters more than the actual finding did in this case.
- The location data has real limits, and I'd rather say that clearly than oversell a pattern that isn't strongly supported.

## How I actually worked through this

The bigger goal of this project was getting comfortable with the loop of: frame a question → describe it to Gemini → get a SQL query back → read it closely enough to know if it's right → run it → interpret the result. A few queries needed a second or third pass because my first prompt was ambiguous (e.g. "highest engagement" could mean several different columns, so I had to be specific about which metric and which aggregation I wanted). Getting better at writing that initial prompt precisely turned out to matter as much as understanding the SQL itself.

I also spent more time than I expected just on BigQuery housekeeping — getting the CSV uploaded cleanly, figuring out project vs. dataset vs. table scoping, fixing a table name that had a space in it, and learning to save and re-run queries instead of rewriting them each time. None of that shows up in the tables above, but it's a real part of what I picked up doing this.
