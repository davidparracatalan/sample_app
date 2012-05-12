FactoryGirl.define do
  factory :user do
    name       "Usuario Prueba Prueba"
    email      "usuariosdeprueba@prueba.test"
    password   "password"
    password_confirmation "password"
  end
end