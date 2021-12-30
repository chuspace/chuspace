# frozen_string_literal: true

john = User.build_with_email_identity(
  email: 'johndoe@chuspace.com',
  username: 'johndoe',
  name: 'John Doe'
)

john.save!

mary = User.build_with_email_identity(
  email: 'marysmith@chuspace.com',
  username: 'marysmith',
  name: 'Mary Smith'
)

mary.save!
