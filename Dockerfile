FROM jekyll/jekyll:3
COPY Gemfile .
RUN bundle install && rm Gemfile
