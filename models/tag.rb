# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#

class Tag < ActsAsTaggableOn::Tag
  def self.hash_for_hint
    tags = []
    select(:name) do |tag|
      tag_hash = {id: tag.name, text: tag.name}
      tags << tag_hash
    end
    tags
  end
end
