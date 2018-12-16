module RedminePgcommunityauth
  module UserPatch
    unloadable

    def self.included(base)
      base.class_eval do
        attr_protected :firstname, :lastname, :mail
      end
    end
  end
end
