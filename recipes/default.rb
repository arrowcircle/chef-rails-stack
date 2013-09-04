# general
include_recipe "rails-stack::general"

include_recipe "rails-stack::users"
include_recipe "rails-stack::directories"
include_recipe "rails-stack::apps"

include_recipe "rails-stack::databases"