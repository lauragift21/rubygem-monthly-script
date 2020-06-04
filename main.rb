require "active_support/core_ext/date"
require "active_support/core_ext/time"

def commits_link_for(repo, date)
  "https://github.com/" << repo << "/compare/master@%7B" <<
    date.beginning_of_month.iso8601 << "%7D...master@%7B" <<
    date.end_of_month.iso8601 << "%7D"
end

puts commits_link_for("rubygems/rubygems.org", Date.parse("2020-05-01"))

def git_summary(repo, date)
  require "http"
  changes_link      = commits_link_for(repo, date)
  puts "Fetching summary information for #{repo}..."

  changes_response  = HTTP.get(changes_link)
  changes_html      = changes_response.body.to_s
  contributor_count = changes_html.match(/([\d,]+)\s+contributors/){|m| m[1].tr(',','').to_i }
  commit_count      = changes_html.match(/Commits\s+<span\s+class="Counter">\s+([\d,]+)\s+<\/span>/){|m| m[1].tr(',','').to_i }
  files_count       = changes_html.match(/([\d,]+)\s+changed\s+files/){|m| m[1].tr(',','').to_i }
  additions_count   = changes_html.match(/([\d,]+)\s+additions/){|m| m[1].tr(',','').to_i }
  deletions_count   = changes_html.match(/([\d,]+)\s+deletions/){|m| m[1].tr(',','').to_i }
  project = repo.split("/").last.capitalize

  # Style options
  # 1. In total, this month 13 authors pushed 149 commits, including 1,668 additions and 306 deletions across 78 files.
  # 2. In total, RubyGems.org gained 21 new commits, with 4 different contributors changing 63 files. There were 851 additions and 305 deletions.
  # 3. In total, Gemstash gained 3 new commits. 2 different authors changed 5 files, with 37 additions and 6 deletions.

  "In #{Date::MONTHNAMES[date.month]}, #{project} gained #{pluralize('new commit', commit_count)}, " \
    "contributed by #{pluralize('author', contributor_count)}. There " \
    "#{additions_count == 1 ? 'was' : 'were'} " \
    "#{pluralize('addition', additions_count)} and " \
    "#{pluralize('deletion', deletions_count)} across " \
    "#{pluralize('file', files_count)}.\n"
end

def pluralize(name, count)
  "#{count} #{name}#{count == 1 ? '' : 's'}"
end

puts git_summary("rubygems/rubygems.org", Date.parse("2020-05-01"))