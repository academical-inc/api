# Monkeypatching BSON::Object
module BSON
  class ObjectId
    # This overrides default JSON representation of an ObjectId
    # Outputs a string id '540f51de6d61632c74020000', instead of
    # { "$oid": '540f51de6d61632c74020000' }
    def as_json(*args)
      to_s
    end
  end
end

# Monkeypatching Mongoid::Document
module Mongoid::Document

  # Overrides ActiveModel::Serialization#serializable_hash for Mongoid Documents
  # If needed, please refer to the original method documentation.
  # Returns serialized_hash of any Mongoid::Document with following conditions:
  #
  #  - For a root document (not embedded) the `:_id` field is replaced for
  #    `:id` field
  #  - For an embedded document :_id field is completely excluded
  #
  # It gracefully keeps any other :only, :except, :methods and :include
  # options originally passed in the `options` hash
  def serializable_hash(options = nil)
    hash = super options
    hash["id"] = self._id if not self.embedded?
    hash.delete("_id")
    hash
  end
end

# Adds a useful Mongoid Exception when trying to insert documents with duplicate
# data which should be unique
module Mongoid::Errors
  class DuplicateKey < StandardError

    attr_reader :fields

    def initialize(ex, fields)
      @ex = ex
      raise @ex if not is_duplicate_key_error?
      @fields = fields
    end

    def is_duplicate_key_error?
      if @ex.respond_to? :details
        [11000, 11001].include?(@ex.details['code'])
      else
        false
      end
    end

    def to_s
      "A resource with the unique fields #{@fields} already exists"
    end
  end
end

# Monkeypatches UnknownAttribute error to be able to access the attribute that
# is unknown and display in error messages
class Mongoid::Errors::UnknownAttribute

  attr_reader :attr_name

  def initialize(klass, name)
    @attr_name = name
    super(
      compose_message("unknown_attribute", { klass: klass.name, name: name })
    )
  end
end
