# TODO: refactor User schema to have username instead of name column
class User < ActiveRecord::Base
    # Given usernames, return hash mapping usernames to users
    def self.users(usernames)
        return Hash[User.where(name: usernames).map {|user| [user.name, user]}]
    end

    # Adds missing users by creating them
    # Params:
    #   usernames: list of unique usernames, both new and missing
    # Returns: All user objects
    def self.add_missing(usernames)
        existing_users = users(usernames)
        existing_usernames = existing_users.keys
        new_usernames = usernames.reject{|name| existing_usernames.include? name}
        new_usernames.each do |name|
            existing_users[name] = User.create(name: name)
        end
        return existing_users.values
    end
end
