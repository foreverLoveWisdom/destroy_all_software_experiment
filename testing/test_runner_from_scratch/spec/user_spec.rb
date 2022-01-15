# frozen_string_literal: true

require_relative '../runner'
require 'sequel'

Sequel.connect 'postgres://localhost/tests'

class User < Sequel::Model(:users)
  def change_email(email)
    update(email: email)
  end
end

describe User do
  def user
    @user ||= User.create(email: 'example@example.com',
                          last_login: Time.new(2022, 10, 21, 10, 22))
  end

  it 'has some attributes' do
    # It is ok to break the rule one assertion per test here
    # If I add new attributes, this test will still pass
    user.email.should == 'example@example.com'
    user.last_login.should == Time.new(2022, 10, 21, 10, 22)
  end

  it 'has some attributes' do
    # If I add new attributes, this test will fail
    user.to_hash.should == {
      id: user.id,
      email: 'example@example.com',
      last_login: Time.new(2022, 10, 21, 10, 22)
    }
  end

  it 'can change email' do
    user.change_email('socrates@gmail.com')
    user.email.should == 'socrates@gmail.com'
  end
end
