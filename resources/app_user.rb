actions :create
default_action :create

attribute :user, :kind_of => String, :required => true
attribute :authorized_keys, :kind_of => [Array, NilClass]

attr_accessor :user, :authorized_keys