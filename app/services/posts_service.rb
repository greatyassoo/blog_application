# frozen_string_literal: true

require "./app/exceptions/not_author_owner_exception"
class PostsService
  def self.save(post_params, user_id)
    # extract tags and query/process them
    tag_values = post_params.delete(:tags)
    tags = query_tag_values(tag_values)


    post = Post.new(post_params)
    post.user_id = user_id
    post.tags = tags
    post.save! # throw exception if not save

    DeletePostJob.perform_in(10.second, { "id" => post.id }) # schedule sidekiq delete job

    PostSerializer.new(post).serializable_hash[:data][:attributes]
  end


  def self.update(post_params, post_id, user_id)
    post = Post.find(post_id) # throws RecordNotFound
    if post.user_id != user_id.to_i
      raise NotAuthorOwnerException.new
    end

    # update post tags
    tag_values = post_params.delete(:tags)
    if tag_values
      tags = query_tag_values(tag_values)
      post.tags = tags
    end

    post.update!(post_params)
  end


  def self.delete_by_id(post_id, user_id)
    post = Post.find(post_id) # throws RecordNotFound
    if post.user_id != user_id.to_i
      raise NotAuthorOwnerException.new
    end

    post.destroy!
  end


  private

  def self.query_tag_values(tag_values)
    if tag_values.present?
      tags = Tag.where(value: tag_values)
      # tags = tag_values.map { |value| Tag.find_by_value(value) }
      if tags.length != tag_values.length
        raise ArgumentError.new("Invalid tag(s)")
      end
    end
    tags
  end
end
