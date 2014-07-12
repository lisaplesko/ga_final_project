namespace :githubdata do

  desc "Download latest WDI github account data"
  task account_info: :environment do
    Student.all.each do |student|
      info = Octokit.user(student.username)
      http = info.blog
      if http
        if http.start_with? "@"
          http.gsub!(/(^\@)/) {""}
          http.insert(0, "twitter.com/")
        end
        http.gsub!(/((http|https)\:\/\/)/) {""}
      end
      student.update!(created_at: info.created_at, avatar_url: info.avatar_url, url: info.html_url, hireable: info.hireable, company: info.company, followers: info.followers, following: info.following, public_repos: info.public_repos, blog: http)
    end
  end


  desc "Download recent commit events"
  task commit_messages: :environment do
    Event.delete_all
    Student.all.each do |student|
      user = Octokit.user(student.username)
      if user.rels[:events].get.data
        count = 0
        user.rels[:events].get.data.each do |event|
          # Prevent empty commit from blowing up rake task
          if event[:type] == "PushEvent" && event[:payload][:commits] != [] && count < 5
            message = event[:payload][:commits][0][:message]
            repo = event[:repo][:name] || ""
            date = event[:created_at] || ""
            student.events << Event.create!(message: message, repo: repo, date: date)
            count += 1
          end
        end
      end
    end
  end

  desc "Download repositories"
  task repos: :environment do
    Repo.delete_all
    Language.delete_all
    Student.all.each do |student|
      puts student.firstname
      repos = Octokit.repos(student.username)
      repos.each do |repo|
        student.repos << Repo.create!(id: repo[:id], name: repo[:name], stargazers_count: repo[:stargazers_count],
                                      watchers_count: repo[:watchers_count], description: repo[:description],
                                      html_url: repo[:html_url], updated: repo[:updated_at], homepage: repo[:homepage])

        languages = Octokit.languages("#{student.username}" + "/" + "#{repo[:name]}").to_h
        languages.each do |k,v|
          Language.create!(lang_name: k, lang_amount: v, repo_id: repo[:id])
        end
      end
    end
  end
end

# Reduce commit data to a more recent date?
# http://www.coderexception.com/C61H11zbUPSQJJJJ/using-ruby-github-api-to-filter-commits-by-date

# rescue Octokit::NotFound
#  false
