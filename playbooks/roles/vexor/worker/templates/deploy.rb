require 'mina/bundler'
require 'mina/git'

set :deploy_to, "{{ vx_home }}/worker"

set :domain, 'worker.example.com'
set :repository, 'git://github.com/{{ vx_worker_repo }}.git'
set :branch, '{{ vx_worker_branch }}'

set :user, '{{ vx_user }}'

set :shared_paths, ['log']

task :environment do
  queue %{
    #{ echo_cmd %{export PATH={{ vx_home }}/bin:$PATH} }
  }
end

task :setup => :environment do
  queue %[mkdir -p "#{deploy_to}/shared/log"]
  queue %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
end

desc "Deploys the current version to the server."
task :deploy => :setup do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue %{
      bundle install --path=#{deploy_to}/shared/bundle --without test --jobs 4
    }
    to :launch do
      invoke :'deploy:cleanup'
    end
  end
end
