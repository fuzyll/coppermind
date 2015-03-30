##
# Coppermind
#
# Copyright (c) 2012-2015 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##

module Coppermind
    begin
        Repository = Git.open("./pages")
    rescue Exception => e
        STDERR.puts e.message
        Repository = nil
    end

    class Page
        def self.content(path)
            begin
                object = Repository.object("HEAD:#{path}.md")
            rescue Exception => e
                STDERR.puts e.message  # FIXME: DEBUG MESSAGE
                return ""
            end
            return object.contents
        end

        def self.update(path, data, message)
            # do nothing if no data was modified
            return if data == Page.content(path)

            # create subdirectories if they don't already exist
            mkdir(path)

            # write data to file
            File.open("./pages/#{path}.md", "w") do |f|
                f.write(data)
            end

            # commit changes to repository
            Dir.chdir("./pages") do
                Repository.add("#{path}.md")
            end
            Repository.commit(message)

            return
        end

        def self.move(old, new, message)
            # create subdirectories if they don't already exist
            mkdir(new)

            # move the file
            Repository.lib.mv("#{old}.md", "#{new}.md")

            # commit change to repository
            Repository.commit(message)
        end

        def self.delete(path, message)
            # delete the file
            Repository.lib.remove("#{path}.md")

            # commit change to repository
            Repository.commit(message)
        end

        def self.history(path)
            commits = []

            begin
                Repository.log.each do |entry|  # FIXME: line below is what I want to use, but there's a bug in the gem
                #Repository.log.object("#{path}.md").each do |entry|
                    commit = {
                        :message => entry.message,
                        :date => entry.date.strftime("%Y-%m-%d at %H:%M:%S %Z"),
                        :author => entry.author.name,
                        :hash => entry.sha,
                    }
                    commits << commit
                end
            rescue Exception => e
                STDERR.puts e.message  # FIXME: DEBUG MESSAGE
                commits = nil
            end

            return commits
        end

        def self.diff(first, second)
            # we assume first and second are the two commit hashes to compare
            return Repository.diff(first, second).patch  # FIXME: not actually tested...
        end

    private
        def self.mkdir(path)
            if path.count('/') > 0
                dirs = "./pages/#{path.split("/")[0..-2].join("/")}"
                FileUtils.mkpath(dirs) if !File.directory?(dirs)
            end
        end
    end
end
