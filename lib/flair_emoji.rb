# frozen_string_literal: true

require_relative 'default_bot'

class FlairEmoji
  CSS_CLASS_TO_TEXT = {
    '42' => 'Jackie Robinson :42:',
    'al-mlbmisc' => 'American League :al:',
    'ari-1' => 'Arizona Diamondbacks :ari2:',
    'ari-2' => 'Arizona Diamondbacks :ari3:',
    'ari-3' => 'Arizona Diamondbacks :ari4:',
    'ari' => 'Arizona Diamondbacks :ari1:',
    'atl-1' => 'Atlanta Braves :atl2:',
    'atl-2' => 'Atlanta Braves :atl3:',
    'atl-3' => 'Boston Braves :atl4:',
    'atl' => 'Atlanta Braves :atl1:',
    'australia-wbc' => 'Australia :au:',
    'bal-1' => 'Baltimore Orioles :bal2:',
    'bal-2' => 'Baltimore Orioles :bal3:',
    'bal-3' => 'St. Louis Browns :bal4:',
    'bal' => 'Baltimore Orioles :bal1:',
    'bk' => 'Brooklyn Dodgers :lad4:',
    'bos-1' => 'Boston Red Sox :bos2:',
    'bos-2' => 'Boston Red Sox :bos3:',
    'bos-3' => 'Boston Americans :bos4:',
    'bos' => 'Boston Red Sox :bos1:',
    'canada-wbc' => 'Canada :ca:',
    'chc-1' => 'Chicago Cubs :chc2:',
    'chc-2' => 'Chicago Cubs :chc3:',
    'chc-3' => 'Chicago Orphans :chc4:',
    'chc' => 'Chicago Cubs :chc1:',
    'chd1-npblogo' => 'Chunichi Dragons :chd1:',
    'chd2-npblogo' => 'Chunichi Dragons :chd2:',
    'china-wbc' => 'China :cn:',
    'chinese-taipei-wbc' => 'Chinese Taipei :ct:',
    'cin-1' => 'Cincinnati Reds :cin2:',
    'cin-2' => 'Cincinnati Reds :cin3:',
    'cin-3' => 'Cincinnati Red Stockings :cin4:',
    'cin' => 'Cincinnati Reds :cin1:',
    'cl-npbmisc' => 'Central League :cl:',
    'cle-1' => 'Cleveland Indians :cle2:',
    'cle-2' => 'Cleveland Indians :cle3:',
    'cle-3' => 'Cleveland Naps :cle4:',
    'cle' => 'Cleveland Indians :cle1:',
    'clm1-npblogo' => 'Chiba Lotte Marines :clm1:',
    'clm2-npblogo' => 'Chiba Lotte Marines :clm2:',
    'col-1' => 'Colorado Rockies :col2:',
    'col-2' => 'Colorado Rockies :col3:',
    'col-3' => 'Colorado Rockies :col4:',
    'col' => 'Colorado Rockies :col1:',
    'colombia-wbc' => 'Colombia :co:',
    'cuba-wbc' => 'Cuba :cu:',
    'cws-1' => 'Chicago White Sox :cws2:',
    'cws-2' => 'Chicago White Sox :cws3:',
    'cws-3' => 'Chicago White Stockings :cws4:',
    'cws' => 'Chicago White Sox :cws1:',
    'det-1' => 'Detroit Tigers :det2:',
    'det-2' => 'Detroit Tigers :det3:',
    'det-3' => 'Detroit Tigers :det4:',
    'det' => 'Detroit Tigers :det1:',
    'dominican-republic-wbc' => 'Dominican Republic :dr:',
    'doosan' => 'Doosan Bears :Bears:',
    'fkh1-npblogo' => 'Fukuoka SoftBank Hawks :fsh1:',
    'fkh2-npblogo' => 'Fukuoka SoftBank Hawks :fsh2:',
    'hanwha' => 'Hanwha Eagles :Eagles:',
    'hhf-npblogo' => 'Hokkaido Nippon Ham Fighters :hhf:',
    'hou-1' => 'Houston Astros :hou2:',
    'hou-2' => 'Houston Astros :hou3:',
    'hou-3' => 'Houston Colt .45s :hou4:',
    'hou' => 'Houston Astros :hou1:',
    'hst-npblogo' => 'Hanshin Tigers :hst:',
    'htc1-npblogo' => 'Hiroshima Toyo Carp :htc1:',
    'htc2-npblogo' => 'Hiroshima Toyo Carp :htc2:',
    'israel-wbc' => 'Israel :il:',
    'italy-wbc' => 'Italy :it:',
    'japan-wbc' => 'Japan :jp:',
    'k-mlbmisc' => 'Strikeout :k:',
    'kbo' => 'KBO :KBO:',
    'kcr-1' => 'Kansas City Royals :kcr2:',
    'kcr-2' => 'Kansas City Royals :kcr3:',
    'kcr-3' => 'Kansas City Royals :kcr4:',
    'kcr' => 'Kansas City Royals :kcr1:',
    'kia' => 'Kia Tigers :Tigers:',
    'kiwoom' => 'Kiwoom Heroes :Heroes:',
    'korea-wbc' => 'Korea :kr:',
    'kt' => 'KT Wiz :Wiz:',
    'laa-1' => 'California Angels :laa2:',
    'laa-2' => 'California Angels :laa3:',
    'laa-3' => 'Los Angeles Angels :laa4:',
    'laa' => 'Los Angeles Angels :laa1:',
    'lad-1' => 'Los Angeles Dodgers :lad2:',
    'lad-2' => 'Los Angeles Dodgers :lad3:',
    'lad' => 'Los Angeles Dodgers :lad1:',
    'lg' => 'LG Twins :Twins:',
    'lotte' => 'Lotte Giants :Giants:',
    'mexico-wbc' => 'Mexico :mx:',
    'mia-1' => 'Miami Marlins :mia2:',
    'mia-2' => 'Miami Marlins :mia3:',
    'mia-3' => 'Florida Marlins :mia4:',
    'mia' => 'Miami Marlins :mia1:',
    'mil-1' => 'Milwaukee Brewers :mil2:',
    'mil-2' => 'Milwaukee Brewers :mil3:',
    'mil-3' => 'Seattle Pilots :mil4:',
    'mil' => 'Milwaukee Brewers :mil1:',
    'min-1' => 'Minnesota Twins :min2:',
    'min-2' => 'Minnesota Twins :min3:',
    'min-3' => 'Washington Nationals :min4:',
    'min' => 'Minnesota Twins :min1:',
    'mlb-mlbmisc' => 'Major League Baseball :mlb:',
    'mon' => 'Montreal Expos :was4:',
    'nc' => 'NC Dinos :Dinos:',
    'netherlands-wbc' => 'Netherlands :ne:',
    'nl-mlbmisc' => 'National League :nl:',
    'npb-npbmisc' => 'Nippon Professional Baseball :npb:',
    'nym-1' => 'New York Mets :nym2:',
    'nym-2' => 'New York Mets :nym3:',
    'nym-3' => 'New York Mets :nym4:',
    'nym' => 'New York Mets :nym1:',
    'nyy-1' => 'New York Yankees :nyy2:',
    'nyy-2' => 'New York Yankees :nyy3:',
    'nyy-3' => 'New York Highlanders :nyy4:',
    'nyy' => 'New York Yankees :nyy1:',
    'oak-1' => 'Oakland Athletics :oak2:',
    'oak-2' => 'Oakland Athletics :oak3:',
    'oak-3' => 'Philadelphia Athletics :oak4:',
    'oak' => 'Oakland Athletics :oak1:',
    'oxb-npblogo' => 'Orix Buffaloes :oxb:',
    'phi-1' => 'Philadelphia Phillies :phi2:',
    'phi-2' => 'Philadelphia Phillies :phi3:',
    'phi-3' => 'Philadelphia Phillies :phi4:',
    'phi' => 'Philadelphia Phillies :phi1:',
    'pit-1' => 'Pittsburgh Pirates :pit2:',
    'pit-2' => 'Pittsburgh Pirates :pit3:',
    'pit-3' => 'Pittsburgh Pirates :pit4:',
    'pit' => 'Pittsburgh Pirates :pit1:',
    'pl-npbmisc' => 'Pacific League :pl:',
    'puerto-rico-wbc' => 'Puerto Rico :pr:',
    'samsung' => 'Samsung Lions :Lions:',
    'sdp-1' => 'San Diego Padres :sdp2:',
    'sdp-2' => 'San Diego Padres :sdp3:',
    'sdp-3' => 'San Diego Padres :sdp4:',
    'sdp' => 'San Diego Padres :sdp1:',
    'sea-1' => 'Seattle Mariners :sea2:',
    'sea-2' => 'Seattle Mariners :sea3:',
    'sea-3' => 'Seattle Mariners :sea4:',
    'sea' => 'Seattle Mariners :sea1:',
    'sfg-1' => 'San Francisco Giants :sfg2:',
    'sfg-2' => 'San Francisco Giants :sfg3:',
    'sfg-3' => 'New York Giants :sfg4:',
    'sfg' => 'San Francisco Giants :sfg1:',
    'sk' => 'SK Wyverns :Wyverns:',
    'stl-1' => 'St. Louis Cardinals :stl2:',
    'stl-2' => 'St. Louis Cardinals :stl3:',
    'stl-3' => 'St. Louis Cardinals :stl4:',
    'stl' => 'St. Louis Cardinals :stl1:',
    'sul-npblogo' => 'Seibu Lions :sul:',
    'tbr-1' => 'Tampa Bay Rays :tbr2:',
    'tbr-2' => 'Tampa Bay Rays :tbr3:',
    'tbr-3' => 'Tampa Bay Rays :tbr4:',
    'tbr' => 'Tampa Bay Rays :tbr1:',
    'tex-1' => 'Texas Rangers :tex2:',
    'tex-2' => 'Texas Rangers :tex3:',
    'tex-3' => 'Washington Senators :tex4:',
    'tex' => 'Texas Rangers :tex1:',
    'tge1-npblogo' => 'Tohoku Rakuten Golden Eagles :tge1:',
    'tge2-npblogo' => 'Tohoku Rakuten Golden Eagles :tge2:',
    'tor-1' => 'Toronto Blue Jays :tor2:',
    'tor-2' => 'Toronto Blue Jays :tor3:',
    'tor-3' => 'Toronto Blue Jays :tor4:',
    'tor' => 'Toronto Blue Jays :tor1:',
    'tys-npblogo' => 'Tokyo Yakult Swallows :tys:',
    'umpire' => 'Umpire :ump:',
    'united-states-wbc' => 'United States :us:',
    'venezuela-wbc' => 'Venezuela :ve:',
    'was-1' => 'Washington Nationals :was2:',
    'was-2' => 'Washington Nationals :was3:',
    'was' => 'Washington Nationals :was1:',
    'wbc-wbc' => 'World Baseball Classic :wbc:',
    'ybs-npblogo' => 'Yokohama BayStars :ybs:',
    'ymg1-npblogo' => 'Yomiuri Giants :ymg1:',
    'ymg2-npblogo' => 'Yomiuri Giants :ymg2:'
  }.freeze

  def initialize
    @bot = DefaultBot.create(purpose: 'Add Emoji to Flairs', account: 'BaseballBot')
    @subreddit = @bot.session.subreddit('baseball')
  end

  def run
    load_flairs after: ARGV[0]
  end

  protected

  def load_flairs(after: nil)
    puts "Loading flairs#{after ? " after #{after}" : ''}"

    res = @subreddit.client
      .get('/r/baseball/api/flairlist', after: after, limit: 1000)
      .body

    res[:users].each { |flair| process_flair(flair) }

    return unless res[:next]

    sleep 5

    load_flairs after: res[:next]
  end

  def process_flair(flair)
    new_text = CSS_CLASS_TO_TEXT[flair[:flair_css_class].downcase]

    return unless new_text && new_text != flair[:flair_text]

    puts "\tChanging #{flair[:user]} from '#{flair[:flair_text]}' to '#{new_text}'"

    @subreddit.set_flair(
      Redd::Models::User.new(nil, name: flair[:user]),
      new_text,
      css_class: flair[:flair_css_class]
    )
  end
end

ConsolidateFlairs.new.run
