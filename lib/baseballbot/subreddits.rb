# frozen_string_literal: true

class Baseballbot
  module Subreddits
    BOT_SUBREDDITS_QUERY = <<~SQL
      SELECT subreddits.*
      FROM subreddits
      LEFT JOIN bots ON (bot_id = bots.id)
    SQL

    # The default subreddits for each team, as used by /r/baseball. These can be overridden on a team-by-team basis
    # by setting `options['subreddits']['XYZ'] = 'OtherSub'` on the Subreddit record.
    # These are capitalized the same way the subreddit's display_name is on /r/.../about.json
    DEFAULT_SUBREDDITS = {
      'ATH' => 'Athletics',
      'ATL' => 'Braves',
      'AZ' => 'azdiamondbacks',
      'BAL' => 'Orioles',
      'BOS' => 'RedSox',
      'CHC' => 'CHICubs',
      'CIN' => 'Reds',
      'CLE' => 'ClevelandGuardians',
      'COL' => 'ColoradoRockies',
      'CWS' => 'WhiteSox',
      'DET' => 'MotorCityKitties',
      'HOU' => 'Astros',
      'KC' => 'KCRoyals',
      'LAA' => 'AngelsBaseball',
      'LAD' => 'Dodgers',
      'MIA' => 'MiamiMarlins',
      'MIL' => 'Brewers',
      'MIN' => 'MinnesotaTwins',
      'NYM' => 'NewYorkMets',
      'NYY' => 'NYYankees',
      'PHI' => 'Phillies',
      'PIT' => 'Buccos',
      'SD' => 'Padres',
      'SEA' => 'Mariners',
      'SF' => 'SFGiants',
      'STL' => 'Cardinals',
      'TB' => 'TampaBayRays',
      'TEX' => 'TexasRangers',
      'TOR' => 'TorontoBlueJays',
      'WSH' => 'Nationals'
    }.freeze

    def name_to_subreddit(name) = (name.is_a?(Subreddit) ? name : subreddits[name.downcase])

    # Default to r/baseball for spring training games against college teams or minor league teams
    def default_subreddit(code) = DEFAULT_SUBREDDITS[code.upcase] || 'baseball'

    protected

    def load_subreddits
      db.exec(BOT_SUBREDDITS_QUERY).to_h { [it['name'].downcase, process_subreddit_row(it)] }
    end

    def process_subreddit_row(row) = Subreddit.new(row, bot: self, bot_account: accounts[row['bot_id']])
  end
end
