class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  strip_attributes
end
