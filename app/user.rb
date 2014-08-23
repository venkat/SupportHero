#Given usernames, return hash mapping usernames to users
def get_users(usernames)
    return Hash[User.where(name: usernames).map {|user| [user.name, user]}]
end

#Adds missing users by creating them
#Params:
# - usernames: list of unique usernames, both new and missing
#Returns: All user objects corresponding to the given usernames
def add_missing_users(usernames)
    existing_users = get_users(usernames)
    existing_usernames = existing_users.keys
    new_usernames = usernames.reject{|name| existing_usernames.include? name}
    new_usernames.each do |name|
        existing_users[name] = User.create(name: name)
    end
    return existing_users
end
