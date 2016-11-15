module DrawBot
  module Database
    # Represents a Discord user
    class User < Sequel::Model
      one_to_one :bank
      one_to_many :transactions

      # Sets up model before creation
      def before_create
        super
        self.timestamp ||= Time.now
      end

      # Updates a User's bank based on their recieved Transactions
      def update_bank
        unless bank.nil?
          unless transactions.empty?
            bank.hearts = transactions.select { |t| t.kind == 'hearts' }
                                      .inject(0) { |a, e| a + e[:amount] }
            bank.salt = transactions.select { |t| t.kind == 'salt' }
                                    .inject(0) { |a, e| a + e[:amount] }
            bank.save
            Discordrb::LOGGER.info "updated bank: #{bank.inspect}"
          end
        end
      end

      # Logs successful User creation
      def after_create
        Discordrb::LOGGER.info "created user: #{inspect}"
      end

      # Fetches Discord user from cache
      # @return [Discordrb::User] the associated user
      def user
        BOT.user(discord_id)
      end
    end
  end
end