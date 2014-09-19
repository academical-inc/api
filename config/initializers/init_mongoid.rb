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
