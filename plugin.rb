# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory
  def self.watch_category!
    update_category = Category.find_by(slug: "Updates")
    update_group = Group.find_by_name("Wartungskunden")

    unless update_category.nil? || update_group.nil?
      update_group.users.each do |user|
        watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], update_category.id) unless watched_categories.include?(update_category.id)
      end
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
