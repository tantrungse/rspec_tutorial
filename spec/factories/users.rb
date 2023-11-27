FactoryBot.define do
    factory :user do
        email { FFaker::Internet.email }
        password { "secret" }
        password_confirmation { "secret" }

        factory :admin do
            admin { true }
        end
    end
end