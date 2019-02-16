#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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

    attr_reader :uniq_field_groups

    def initialize(ex, uniq_field_groups)
      @ex = ex
      raise @ex if not is_duplicate_key_error?
      @uniq_field_groups = uniq_field_groups
    end

    def is_duplicate_key_error?
      @ex.message =~ /^E11000/
    end

    def to_s
      "A resource with the unique fields #{@uniq_field_groups} already exists"
    end
  end

  class DocumentsNotFound < StandardError

    attr_reader :found, :not_found

    def initialize(found, not_found)
      @found = found
      @not_found = not_found
    end

    def to_s
      "#{@not_found} out of #{@found + @not_found} resources where not found"
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
