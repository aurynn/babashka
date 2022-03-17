postgres_install() {
  postgres.install 14
}

postgres_user_create() {
  postgres.user.create "test" -p "testpassword"
}

postgres_user_create_superuser() {
  postgres.user.create "test" -p "testpassword" -s
}

postgres_user_remove() {
  postgres.user.absent "test"
}
