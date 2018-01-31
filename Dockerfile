FROM stcenergy/ruby-24-alpine:0.0.4
COPY . /app/
EXPOSE 4581
WORKDIR /app
RUN cd /app/ && rm Gemfile.lock && bundle install --without development test
CMD RACK_ENV=production bundle exec rackup -p 4581 --host 0.0.0.0