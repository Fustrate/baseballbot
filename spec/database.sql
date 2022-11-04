--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Homebrew)
-- Dumped by pg_dump version 14.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    name character varying,
    access_token character varying,
    refresh_token character varying,
    scope character varying[] DEFAULT '{}'::character varying[],
    expires_at timestamp(6) without time zone
);


ALTER TABLE public.accounts OWNER TO baseballbot;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_id_seq OWNER TO baseballbot;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO baseballbot;

--
-- Name: bot_actions; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.bot_actions (
    id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    action character varying NOT NULL,
    note character varying,
    data jsonb,
    date timestamp(6) without time zone DEFAULT now()
);


ALTER TABLE public.bot_actions OWNER TO baseballbot;

--
-- Name: bot_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.bot_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bot_actions_id_seq OWNER TO baseballbot;

--
-- Name: bot_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.bot_actions_id_seq OWNED BY public.bot_actions.id;


--
-- Name: edits; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.edits (
    id bigint NOT NULL,
    editable_type character varying NOT NULL,
    editable_id bigint NOT NULL,
    user_type character varying NOT NULL,
    user_id bigint NOT NULL,
    note text,
    reason character varying,
    pretty_changes jsonb DEFAULT '{}'::jsonb NOT NULL,
    raw_changes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.edits OWNER TO baseballbot;

--
-- Name: edits_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.edits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.edits_id_seq OWNER TO baseballbot;

--
-- Name: edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.edits_id_seq OWNED BY public.edits.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.events (
    id integer NOT NULL,
    eventable_type character varying,
    eventable_id integer,
    type character varying,
    note character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_type character varying NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.events OWNER TO baseballbot;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO baseballbot;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: game_threads; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.game_threads (
    id integer NOT NULL,
    post_at timestamp(6) without time zone,
    starts_at timestamp(6) without time zone,
    status character varying,
    title character varying,
    post_id character varying,
    created_at timestamp(6) without time zone DEFAULT now(),
    updated_at timestamp(6) without time zone DEFAULT now(),
    subreddit_id integer NOT NULL,
    game_pk integer,
    type character varying,
    pre_game_post_id character varying,
    post_game_post_id character varying
);


ALTER TABLE public.game_threads OWNER TO baseballbot;

--
-- Name: game_threads_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.game_threads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.game_threads_id_seq OWNER TO baseballbot;

--
-- Name: game_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.game_threads_id_seq OWNED BY public.game_threads.id;


--
-- Name: scheduled_posts; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.scheduled_posts (
    id integer NOT NULL,
    next_post_at timestamp(6) without time zone,
    title character varying,
    body text,
    subreddit_id integer NOT NULL,
    options jsonb
);


ALTER TABLE public.scheduled_posts OWNER TO baseballbot;

--
-- Name: scheduled_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.scheduled_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.scheduled_posts_id_seq OWNER TO baseballbot;

--
-- Name: scheduled_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.scheduled_posts_id_seq OWNED BY public.scheduled_posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO baseballbot;

--
-- Name: subreddits; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.subreddits (
    id integer NOT NULL,
    name character varying,
    team_code character varying,
    account_id integer,
    options jsonb,
    team_id integer,
    slack_id character varying,
    moderators character varying[] DEFAULT '{}'::character varying[]
);


ALTER TABLE public.subreddits OWNER TO baseballbot;

--
-- Name: subreddits_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.subreddits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subreddits_id_seq OWNER TO baseballbot;

--
-- Name: subreddits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.subreddits_id_seq OWNED BY public.subreddits.id;


--
-- Name: subreddits_users; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.subreddits_users (
    subreddit_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.subreddits_users OWNER TO baseballbot;

--
-- Name: system_users; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.system_users (
    id bigint NOT NULL,
    username character varying NOT NULL,
    description character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.system_users OWNER TO baseballbot;

--
-- Name: system_users_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.system_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_users_id_seq OWNER TO baseballbot;

--
-- Name: system_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.system_users_id_seq OWNED BY public.system_users.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.templates (
    id integer NOT NULL,
    body text,
    type character varying,
    subreddit_id integer,
    created_at timestamp(6) without time zone,
    updated_at timestamp(6) without time zone
);


ALTER TABLE public.templates OWNER TO baseballbot;

--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.templates_id_seq OWNER TO baseballbot;

--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.templates_id_seq OWNED BY public.templates.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: baseballbot
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username public.citext NOT NULL,
    crypted_password character varying,
    salt character varying,
    last_activity_at timestamp(6) without time zone,
    last_login_at timestamp(6) without time zone,
    last_logout_at timestamp(6) without time zone,
    last_login_from_ip_address character varying,
    remember_me_token_expires_at timestamp(6) without time zone,
    remember_me_token character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO baseballbot;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: baseballbot
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO baseballbot;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: baseballbot
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: bot_actions id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.bot_actions ALTER COLUMN id SET DEFAULT nextval('public.bot_actions_id_seq'::regclass);


--
-- Name: edits id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.edits ALTER COLUMN id SET DEFAULT nextval('public.edits_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: game_threads id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.game_threads ALTER COLUMN id SET DEFAULT nextval('public.game_threads_id_seq'::regclass);


--
-- Name: scheduled_posts id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.scheduled_posts ALTER COLUMN id SET DEFAULT nextval('public.scheduled_posts_id_seq'::regclass);


--
-- Name: subreddits id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.subreddits ALTER COLUMN id SET DEFAULT nextval('public.subreddits_id_seq'::regclass);


--
-- Name: system_users id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.system_users ALTER COLUMN id SET DEFAULT nextval('public.system_users_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.templates ALTER COLUMN id SET DEFAULT nextval('public.templates_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.accounts (id, name, access_token, refresh_token, scope, expires_at) FROM stdin;
2	DodgerBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
3	sfgbot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
4	Rangers_Bot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
5	angelsbaseball	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 13:59:59
6	RedSoxGameday	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
7	RaysBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
8	Mariners_bot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
9	MarlinsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
10	BlueJaysBaseball	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
11	BrewersBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
12	AthleticsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
14	HeltonsGoatee	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
16	ChiCubsbot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
17	RedsModerator	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
18	Fustrateaaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
19	SnakeBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
20	OsGameThreads	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
21	Yankeebot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
22	TigersBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
23	KCRoyalsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
24	AstrosBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
25	PhilsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread}	2025-12-31 23:59:59
26	TwinsGameday	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
27	NewYorkMetsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
28	CLEBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
29	chisoxbot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 23:59:59
30	NationalsBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 13:59:59
1	BaseballBot	aaaa	zzzz	{identity,edit,modconfig,modflair,modposts,read,submit,wikiread,flair}	2025-12-31 13:59:59
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2022-01-06 15:28:24.97692	2022-01-06 15:28:24.97692
schema_sha1	d0869c26d3ea519ac1b6ff12a9e3833073a696d5	2022-01-06 15:28:24.98208	2022-01-06 15:28:24.98208
\.


--
-- Data for Name: bot_actions; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.bot_actions (id, subject_type, subject_id, action, note, data, date) FROM stdin;
\.


--
-- Data for Name: edits; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.edits (id, editable_type, editable_id, user_type, user_id, note, reason, pretty_changes, raw_changes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.events (id, eventable_type, eventable_id, type, note, created_at, updated_at, user_type, user_id) FROM stdin;
\.


--
-- Data for Name: game_threads; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.game_threads (id, post_at, starts_at, status, title, post_id, created_at, updated_at, subreddit_id, game_pk, type, pre_game_post_id, post_game_post_id) FROM stdin;
2	2022-05-17 17:10:00	2022-05-17 15:10:00	Future	\N	\N	2022-05-15 11:12:17.124634	2022-05-15 11:12:17.136276	15	663032	\N	\N	\N
3	2022-05-17 13:40:00	2022-05-17 15:40:00	Future	\N	\N	2022-05-15 11:16:18.46372	2022-05-15 11:16:18.467421	15	662053	\N	\N	\N
4	2022-05-15 12:10:00	2022-05-15 13:10:00	Future	\N	\N	2022-05-15 11:17:41.533325	2022-05-15 11:17:41.535708	1	662696	\N	\N	\N
6	2022-05-15 10:10:00	2022-05-15 11:10:00	Future	Test %<one>d two three	\N	2022-05-15 11:45:47.11991	2022-05-15 11:45:47.124299	24	661732	\N	\N	\N
\.


--
-- Data for Name: scheduled_posts; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.scheduled_posts (id, next_post_at, title, body, subreddit_id, options) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.schema_migrations (version) FROM stdin;
20211010070253
20180308202459
20180331181802
20180404032107
20180429223112
20180901001353
20180912155358
20180912201118
20180916205420
20180916212407
20181025005935
20181025011756
20190323191654
20200119223746
20200204004826
20200204010243
20200309053109
20220502062052
20220502070727
20220502152728
20220506170453
20220506171415
20221016212936
\.


--
-- Data for Name: subreddits; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.subreddits (id, name, team_code, account_id, options, team_id, slack_id, moderators) FROM stdin;
2	sfgiants	SF	3	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "POSTGAME THREAD: %<away_name>s @ %<home_name>s, %-m/%-d. Join the Giants game / baseball discussion and social thread!", "postseason": "POSTGAME THREAD: %<series_game>s - %<away_name>s @ %<home_name>s, %-m/%-d. Join the Giants game / baseball discussion and social thread!"}, "enabled": true}, "timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "Gameday Thread %-m/%-d/%y %<away_name>s (%<away_pitcher>s) @ %<home_name>s (%<home_pitcher>s) %<start_time>s", "postseason": "Gameday Thread %-m/%-d/%y - %<series_game>s - %<away_name>s (%<away_pitcher>s) @ %<home_name>s (%<home_pitcher>s) %<start_time>s"}, "enabled": true, "post_at": "4am"}}	137	\N	{}
3	texasrangers	TEX	4	{"sidebar": {"enabled": true}, "timezone": "America/Chicago", "game_threads": {"title": {"default": "Game Chat: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s"}, "enabled": true, "post_at": "-12", "flair_id": {"won": "051fb5f6-a339-11e2-951f-12313d164929", "lost": "55f74ba8-a337-11e2-8e9c-12313d1841d1", "default": "468158ca-b431-11e2-afa3-12313d169640"}}}	140	\N	{}
4	angelsbaseball	LAA	5	{"timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "%-m/%-d %<away_name>s @ %<home_name>s [Game Thread]"}, "enabled": true, "post_at": "-3", "flair_id": {"default": "d0b3f0c2-f1b1-11eb-bc83-46abd969af59"}}}	108	\N	{}
5	redsox	BOS	6	{"pregame": {"title": {"default": "Pregame Thread: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Pregame Thread: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-10", "flair_id": "439662d6-6dc4-11e6-a436-0e8f1ac0db67"}, "sidebar": {"enabled": true}, "postgame": {"title": {"default": "Post Game Thread: %-m/%-d %<away_name>s @ %<home_name>s", "postseason": "Post Game Thread: %-m/%-d - %<series_game>s - %<away_name>s @ %<home_name>s"}, "enabled": true, "flair_id": {"default": "317eee74-6dc4-11e6-9a1e-0e3ced70543b"}}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game Thread: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Thread: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-3", "flair_id": {"default": "06b4531c-ce6c-11e4-adf5-22000bb26ab4"}}}	111	\N	{}
6	tampabayrays	TB	7	{"sidebar": {"enabled": true}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game Chat: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "sticky": false, "enabled": true, "post_at": "5am"}}	139	\N	{}
7	mariners	SEA	8	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Post Game Chat %-m/%-d %<away_name>s @ %<home_name>s"}, "enabled": true}, "timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "Game Chat: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s"}, "enabled": true, "post_at": "-3"}}	136	\N	{}
8	letsgofish	MIA	9	{"sidebar": {"enabled": true}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game Thread: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s"}, "enabled": true, "post_at": "-3"}}	146	\N	{}
9	torontobluejays	TOR	10	{"pregame": {"title": {"default": "Pregame Thread: %B %-d - %<away_full_name>s (%<away_record>s) @ %<home_full_name>s (%<home_record>s) - %<start_time>s"}, "enabled": true, "post_at": "-11"}, "sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread: %B %-d - %<away_full_name>s @ %<home_full_name>s"}, "enabled": true}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game Thread: %B %-d - %<away_full_name>s (%<away_record>s) @ %<home_full_name>s (%<home_record>s) - %<start_time>s"}, "enabled": true, "post_at": "-3"}}	141	\N	{}
10	brewers	MIL	11	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread: %-m/%-d %<away_name>s @ %<home_name>s", "postseason": "Postgame Thread: %-m/%-d - %<series_game>s - %<away_name>s @ %<home_name>s"}, "enabled": true}, "timezone": "America/Chicago", "game_threads": {"title": {"default": "Game Chat: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-3"}}	158	\N	{}
11	oaklandathletics	OAK	12	{"pregame": {"title": {"default": "[Pregame Thread] %<away_full_name>s (%<away_record>s) @ %<home_full_name>s (%<home_record>s) | %-m/%-d/%y @ %<start_time>s", "postseason": "[Pregame Thread] %<series_game>s | %<away_full_name>s (%<away_wins>d) @ %<home_full_name>s (%<home_wins>d) | %-m/%-d/%y @ %<start_time>s"}, "enabled": false, "post_at": "2:00"}, "sidebar": {"enabled": true}, "postgame": {"title": {"default": "[Postgame Thread] %<away_name>s @ %<home_name>s | %-m/%-d/%y", "postseason": "[Postgame Thread] %<series_game>s | %<away_name>s @ %<home_name>s | %-m/%-d/%y"}, "enabled": true}, "timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "Game Chat: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "6am"}}	133	\N	{}
13	coloradorockies	COL	14	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread %-m/%-d %<away_name>s @ %<home_name>s", "postseason": "Postgame Thread %-m/%-d - %<series_game>s - %<away_name>s @ %<home_name>s"}, "enabled": true}, "timezone": "America/Denver", "game_threads": {"title": {"default": "Game Chat %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-3"}}	115	\N	{}
14	nyyankees	NYY	21	{"sidebar": {"enabled": true}, "timezone": "America/New_York"}	147	\N	{}
15	baseball	MLB	1	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread ⚾ %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s", "postseason": "%<series_game>s Postgame Thread ⚾ %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s"}, "sticky": false, "enabled": false}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game of the Day %-m/%-d ⚾ %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time_et>s", "wildcard": "Game Thread: %<series_game>s ⚾ %<away_name>s @ %<home_name>s - %<start_time_et>s", "postseason": "Game Thread: %<series_game>s ⚾ %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %<start_time_et>s"}, "sticky": false, "enabled": true, "flair_id": {"default": "0b55544c-f892-11e5-8419-0e9dc1ca97af"}}}	\N	T0KEXQR25	{}
16	kcroyals	KC	23	{"sidebar": {"enabled": true}, "timezone": "America/Chicago"}	118	\N	{}
17	orioles	BAL	20	{"sidebar": {"enabled": true}, "timezone": "America/New_York"}	110	\N	{}
18	astros	HOU	24	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Post Game Thread (%b %-d, %Y): %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s)", "postseason": "Post Game Thread %<series_game>s (%b %-d, %Y): %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s)"}, "enabled": true}, "timezone": "America/Chicago", "game_threads": {"title": {"default": "Game Thread: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %b %-d, %Y %<start_time>s", "postseason": "Game Thread - %<series_game>s: %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %b %-d, %Y %<start_time>s"}, "enabled": true, "post_at": "6am"}}	117	\N	{}
19	azdiamondbacks	ARI	19	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "POSTGAME THREAD %-m/%-d - %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s)"}, "enabled": true}, "timezone": "America/Phoenix", "game_threads": {"title": {"default": "GAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %<start_time>s"}, "enabled": true}}	109	\N	{}
20	minnesotatwins	MIN	26	{"off_day": {"title": "OFF DAY THREAD: %B %-d, %Y", "sticky": true, "enabled": true, "post_at": "5:00", "last_run_at": "2021-11-03 03:00:08"}, "pregame": {"title": {"default": "PRE GAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %B %-d, %Y"}, "sticky": false, "enabled": true, "post_at": "9:00"}, "sidebar": {"enabled": true}, "postgame": {"title": {"won": "TWINS WIN: %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s - %B %-d, %Y", "lost": "Twins Lost: %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s - %B %-d, %Y", "default": "POST GAME THREAD: %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s - %B %-d, %Y"}, "sticky": false, "enabled": true}, "timezone": "America/Chicago", "sticky_slot": 2, "game_threads": {"title": {"default": "GAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %B %-d, %Y", "postseason": "GAME THREAD: %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %B %-d, %Y"}, "sticky": true, "enabled": true, "post_at": "-1"}}	142	\N	{}
21	motorcitykitties	DET	22	{"sidebar": {"enabled": true}, "timezone": "America/Detroit"}	116	\N	{}
22	newyorkmets	NYM	27	{"sidebar": {"enabled": true}, "timezone": "America/New_York"}	121	\N	{}
23	reds	CIN	17	{"sidebar": {"enabled": true}, "timezone": "America/New_York"}	113	\N	{}
24	baseballtest	MLB	1	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread ⚾ %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s", "postseason": "%<series_game>s Postgame Thread ⚾ %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s"}, "enabled": true}, "timezone": "America/New_York", "game_threads": {"title": {"default": "Game of the Week %-m/%-d ⚾ %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time_et>s", "wildcard": "Game Thread: %<series_game>s ⚾ %<away_name>s @ %<home_name>s - %<start_time_et>s", "postseason": "Game Thread: %<series_game>s ⚾ %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %<start_time_et>s"}, "enabled": true, "flair_id": {"default": "5e54f2f2-00d9-11e6-aece-0ede26d344a9"}}}	\N	\N	{}
25	chicubs	CHC	16	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread: %-m/%-d %<away_name>s @ %<home_name>s", "postseason": "Postgame Thread: %-m/%-d - %<series_game>s - %<away_name>s @ %<home_name>s"}, "enabled": true}, "timezone": "America/Chicago", "game_threads": {"title": {"default": "GDT: %-m/%-d %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "GDT: %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-3"}}	112	\N	{}
26	nationals	WSH	30	{"timezone": "America/New_York", "game_threads": {"title": {"default": "GAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %B %-d, %Y", "postseason": "GAME THREAD: %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %B %-d, %Y"}, "sticky": false, "enabled": true, "post_at": "-2"}}	120	\N	{}
27	phillies	PHI	25	{"sidebar": {"enabled": true}, "timezone": "America/New_York"}	143	\N	{}
28	padres	SD	1	{"timezone": "America/Los_Angeles"}	135	\N	{}
29	buccos	PIT	1	{"timezone": "America/New_York"}	134	\N	{}
30	cardinals	STL	1	{"timezone": "America/Chicago"}	138	\N	{}
31	braves	ATL	1	{"timezone": "America/New_York"}	144	\N	{}
32	whitesox	CWS	29	{"pregame": {"title": {"default": "PREGAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %a %b %-d @ %<start_time>s", "postseason": "PREGAME THREAD: %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %a %b %-d @ %<start_time>s"}, "enabled": false, "post_at": "5:00"}, "sidebar": {"enabled": true}, "postgame": {"title": {"default": "POST GAME THREAD: %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s - %a %b %-d @ %<start_time>s", "postseason": "POST GAME THREAD: %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %a %b %-d @ %<start_time>s"}, "enabled": true}, "timezone": "America/Chicago", "game_threads": {"title": {"default": "GAME THREAD: %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %a %b %-d @ %<start_time>s", "postseason": "GAME THREAD: %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %a %b %-d @ %<start_time>s"}, "enabled": true, "post_at": "-3", "flair_id": {"default": "95f8093e-ddee-11e3-a58b-12313b089471"}}}	145	\N	{}
33	clevelandindians	CLE	28	{"pregame": {"title": {"default": "[General Discussion] Tribe Talk - %A, %B %-d, %Y", "postseason": "[General Discussion] Tribe Talk - %<series_game>s - %A, %B %-d, %Y"}, "enabled": true, "post_at": "5:00"}, "sidebar": {"enabled": true}, "postgame": {"title": {"default": "[Postgame Thread] %<away_name>s @ %<home_name>s - %B %-d, %Y", "postseason": "[Postgame Thread] %<series_game>s - %<away_name>s @ %<home_name>s - %B %-d, %Y"}, "enabled": true}, "timezone": "America/New_York", "game_threads": {"title": {"default": "[Game Thread] %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) - %B %-d, %Y", "postseason": "[Game Thread] %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) - %B %-d, %Y"}, "enabled": true, "post_at": "-1"}}	114	\N	{}
1	dodgers	LAD	2	{"sidebar": {"enabled": true}, "postgame": {"title": {"default": "Postgame Thread ⚾ %<away_name>s %<away_runs>s @ %<home_name>s %<home_runs>s"}, "enabled": true, "flair_id": {"won": "4dc1dd68-cb69-11e2-a81b-12313d14782d", "lost": "50e93978-cb69-11e2-8793-12313d14782d"}}, "timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "Game Chat %-m/%-d - %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-1", "flair_id": {"default": "19b177de-0766-11e3-ab63-12313b08e221"}}}	119	T0TQRUB6J	{Fustrate}
34	troxellophilus	MLB	2	{"off_day": {"sticky_comment": "OFF DAY THREAD GO WILD"}, "pregame": {"sticky_comment": "**test**"}, "postgame": {"enabled": true, "sticky_comment": "postgame?"}, "timezone": "America/Los_Angeles", "game_threads": {"title": {"default": "Game Chat %-m/%-d - %<away_name>s (%<away_record>s) @ %<home_name>s (%<home_record>s) %<start_time>s", "postseason": "Game Chat %-m/%-d - %<series_game>s - %<away_name>s (%<away_wins>d) @ %<home_name>s (%<home_wins>d) %<start_time>s"}, "enabled": true, "post_at": "-3", "sticky_comment": "Game Thread Comment!\\r\\n\\r\\nJoin us on Discord"}}	\N	\N	{}
\.


--
-- Data for Name: subreddits_users; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.subreddits_users (subreddit_id, user_id) FROM stdin;
\.


--
-- Data for Name: system_users; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.system_users (id, username, description, created_at, updated_at) FROM stdin;
1	BaseballBot	\N	2022-05-06 10:15:07.03258	2022-05-06 10:15:07.03258
\.


--
-- Data for Name: templates; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.templates (id, body, type, subreddit_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: baseballbot
--

COPY public.users (id, username, crypted_password, salt, last_activity_at, last_login_at, last_logout_at, last_login_from_ip_address, remember_me_token_expires_at, remember_me_token, created_at, updated_at) FROM stdin;
\.


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.accounts_id_seq', 1, false);


--
-- Name: bot_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.bot_actions_id_seq', 1, false);


--
-- Name: edits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.edits_id_seq', 1, false);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.events_id_seq', 4, true);


--
-- Name: game_threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.game_threads_id_seq', 6, true);


--
-- Name: scheduled_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.scheduled_posts_id_seq', 1, false);


--
-- Name: subreddits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.subreddits_id_seq', 1, false);


--
-- Name: system_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.system_users_id_seq', 1, true);


--
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.templates_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: baseballbot
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bot_actions bot_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.bot_actions
    ADD CONSTRAINT bot_actions_pkey PRIMARY KEY (id);


--
-- Name: edits edits_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.edits
    ADD CONSTRAINT edits_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: game_threads game_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.game_threads
    ADD CONSTRAINT game_threads_pkey PRIMARY KEY (id);


--
-- Name: scheduled_posts scheduled_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.scheduled_posts
    ADD CONSTRAINT scheduled_posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subreddits subreddits_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.subreddits
    ADD CONSTRAINT subreddits_pkey PRIMARY KEY (id);


--
-- Name: system_users system_users_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.system_users
    ADD CONSTRAINT system_users_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_bot_actions_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_bot_actions_on_subject_type_and_subject_id ON public.bot_actions USING btree (subject_type, subject_id);


--
-- Name: index_edits_on_editable; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_edits_on_editable ON public.edits USING btree (editable_type, editable_id);


--
-- Name: index_edits_on_user; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_edits_on_user ON public.edits USING btree (user_type, user_id);


--
-- Name: index_events_on_eventable_type_and_eventable_id; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_events_on_eventable_type_and_eventable_id ON public.events USING btree (eventable_type, eventable_id);


--
-- Name: index_events_on_user_type_and_user_id; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_events_on_user_type_and_user_id ON public.events USING btree (user_type, user_id);


--
-- Name: index_game_threads_on_game_pk_subreddit_date_type_unique; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE UNIQUE INDEX index_game_threads_on_game_pk_subreddit_date_type_unique ON public.game_threads USING btree (game_pk, subreddit_id, date_trunc('day'::text, starts_at), type);


--
-- Name: index_game_threads_on_game_pk_subreddit_date_unique; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE UNIQUE INDEX index_game_threads_on_game_pk_subreddit_date_unique ON public.game_threads USING btree (game_pk, subreddit_id, date_trunc('day'::text, starts_at)) WHERE (type IS NULL);


--
-- Name: index_subreddits_users_on_subreddit_id; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_subreddits_users_on_subreddit_id ON public.subreddits_users USING btree (subreddit_id);


--
-- Name: index_subreddits_users_on_user_id; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_subreddits_users_on_user_id ON public.subreddits_users USING btree (user_id);


--
-- Name: index_users_on_last_logout_at_and_last_activity_at; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_users_on_last_logout_at_and_last_activity_at ON public.users USING btree (last_logout_at, last_activity_at);


--
-- Name: index_users_on_remember_me_token; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE INDEX index_users_on_remember_me_token ON public.users USING btree (remember_me_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: baseballbot
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: subreddits fk_rails_5c51af90f1; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.subreddits
    ADD CONSTRAINT fk_rails_5c51af90f1 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: scheduled_posts fk_rails_6bce9e4887; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.scheduled_posts
    ADD CONSTRAINT fk_rails_6bce9e4887 FOREIGN KEY (subreddit_id) REFERENCES public.subreddits(id);


--
-- Name: game_threads fk_rails_73eaa02464; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.game_threads
    ADD CONSTRAINT fk_rails_73eaa02464 FOREIGN KEY (subreddit_id) REFERENCES public.subreddits(id);


--
-- Name: subreddits_users fk_rails_ccb5722fde; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.subreddits_users
    ADD CONSTRAINT fk_rails_ccb5722fde FOREIGN KEY (subreddit_id) REFERENCES public.subreddits(id);


--
-- Name: templates fk_rails_d1983f5278; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.templates
    ADD CONSTRAINT fk_rails_d1983f5278 FOREIGN KEY (subreddit_id) REFERENCES public.subreddits(id);


--
-- Name: subreddits_users fk_rails_ecc7abde1b; Type: FK CONSTRAINT; Schema: public; Owner: baseballbot
--

ALTER TABLE ONLY public.subreddits_users
    ADD CONSTRAINT fk_rails_ecc7abde1b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

