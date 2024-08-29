# Projet de Vente aux Enchères

Ce projet est une application backend pour une plateforme de vente aux enchères. Il permet aux utilisateurs de créer des comptes, de mettre en vente des objets, de faire des enchères, et de finaliser des transactions. Le projet utilise Ruby on Rails et intègre plusieurs fonctionnalités telles que l'authentification avec Devise, les autorisations avec Pundit, les paiements avec Stripe, et les notifications par e-mail et WebSockets.

## Table des Matières

- [Installation](#installation)
- [Configuration](#configuration)
- [Structure du Projet](#structure-du-projet)
- [Modèles](#modèles)
- [Contrôleurs](#contrôleurs)
- [Routes](#routes)
- [Sécurité et Authentification](#sécurité-et-authentification)
- [Gestion des Transactions](#gestion-des-transactions)
- [Gestion des Notifications](#gestion-des-notifications)
- [Contribution](#contribution)
- [Licence](#licence)

## Installation

Pour installer et configurer le projet, suivez les étapes suivantes :

1. Clonez le dépôt :

```sh
git clone https://github.com/votre-utilisateur/votre-projet.git
cd votre-projet
```

2. Installez les dépendances :

```sh
bundle install
```

3. Configurez la base de données :

```sh
rails db:create
rails db:migrate
```

4. Démarrez le serveur :

```sh
rails server
```

## Configuration

### Variables d'Environnement

Créez un fichier `.env` à la racine du projet et ajoutez les variables d'environnement nécessaires :

```env
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
STRIPE_SECRET_KEY=your_stripe_secret_key
```

### Configuration de l'E-mail

Configurez les paramètres SMTP dans `config/environments/development.rb` et `config/environments/production.rb` :

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'yourdomain.com',
  user_name: 'your-email@gmail.com',
  password: 'your-email-password',
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## Structure du Projet

### Dossiers Principaux

- **app/** : Contient le code de l'application, y compris les modèles, les contrôleurs, les vues, les mailers, et les canaux.
- **config/** : Contient les fichiers de configuration de l'application.
- **db/** : Contient les migrations de la base de données et les schémas.
- **lib/** : Contient les modules et les classes supplémentaires.
- **log/** : Contient les fichiers de log de l'application.
- **public/** : Contient les fichiers statiques.
- **test/** : Contient les tests de l'application.
- **tmp/** : Contient les fichiers temporaires.
- **vendor/** : Contient les dépendances externes.

## Modèles

### Modèle `User`

Les modèles utilisateurs gèrent les informations des utilisateurs, y compris l'authentification et l'autorisation.

**Fichier** : `app/models/user.rb`

**Rôle** : Définit le modèle `User` qui représente les utilisateurs de l'application.

```ruby
class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password

  has_many :items, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :transactions, dependent: :destroy
end
```

### Modèle `Item`

Les modèles objets en vente définissent les objets mis en vente, incluant les détails des objets, les images, le prix de départ, et la durée de l'enchère.

**Fichier** : `app/models/item.rb`

**Rôle** : Définit le modèle `Item` qui représente les objets mis en vente.

```ruby
class Item < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :destroy
  has_one :transaction, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :starting_price, presence: true, numericality: { greater_than: 0 }
  validates :auction_duration, presence: true
  validates :auction_end_time, presence: true
end
```

### Modèle `Bid`

Les modèles enchères gèrent les enchères en cours, les offres placées, et les résultats.

**Fichier** : `app/models/bid.rb`

**Rôle** : Définit le modèle `Bid` qui représente les enchères sur les objets.

```ruby
class Bid < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates :bid_amount, presence: true, numericality: { greater_than: 0 }
  validate :bid_amount_greater_than_starting_price

  private

  def bid_amount_greater_than_starting_price
    if bid_amount.present? && item.present? && bid_amount <= item.starting_price
      errors.add(:bid_amount, "must be greater than the starting price")
    end
  end
end
```

### Modèle `Transaction`

Les modèles transactions suivent les ventes finalisées, les informations de paiement, et les statuts de livraison.

**Fichier** : `app/models/transaction.rb`

**Rôle** : Définit le modèle `Transaction` qui représente les transactions finalisées.

```ruby
class Transaction < ApplicationRecord
  belongs_to :item
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'

  validates :final_price, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, presence: true
  validates :delivery_status, presence: true
end
```
**Conclusion** : Le développement des modèles est une étape cruciale pour définir la structure des données et les comportements associés à chaque entité de notre application. En utilisant les modèles de Rails, nous pouvons gérer les informations des utilisateurs, les objets en vente, les enchères et les transactions de manière cohérente et sécurisée. Les modèles permettent également de valider les données, de gérer les relations entre les entités, et de définir des comportements spécifiques pour chaque entité. 

## Contrôleurs

### Contrôleur `UsersController`

**Fichier** : `app/controllers/api/v1/users_controller.rb`

**Rôle** : Gère les requêtes API pour les utilisateurs.

```ruby
module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        @users = User.all
        render json: @users
      end

      # GET /api/v1/users/:id
      def show
        render json: @user
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user, status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:username, :email, :password)
      end
    end
  end
end
```
**Explication** : 

    GET /api/v1/users : Récupère la liste de tous les utilisateurs.
    GET /api/v1/users/ : Récupère les détails d'un utilisateur spécifique.
    POST /api/v1/users : Crée un nouvel utilisateur.
    PUT /api/v1/users/ : Met à jour un utilisateur existant.
    DELETE /api/v1/users/ : Supprime un utilisateur.

### Contrôleur `ItemsController`

**Fichier** : `app/controllers/api/v1/items_controller.rb`

**Rôle** : Gère les requêtes API pour les objets.

```ruby
module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: [:show, :update, :destroy]

      # GET /api/v1/items
      def index
        @items = Item.all
        render json: @items
      end

      # GET /api/v1/items/:id
      def show
        render json: @item
      end

      # POST /api/v1/items
      def create
        @item = Item.new(item_params)
        if @item.save
          render json: @item, status: :created
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/items/:id
      def update
        if @item.update(item_params)
          render json: @item
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/items/:id
      def destroy
        @item.destroy
        head :no_content
      end

      private

      def set_item
        @item = Item.find(params[:id])
      end

      def item_params
        params.require(:item).permit(:user_id, :title, :description, :starting_price, :auction_duration, :auction_end_time)
      end
    end
  end
end
```
**Explication** : 

    GET /api/v1/items : Récupère la liste de tous les objets en vente.
    GET /api/v1/items/ : Récupère les détails d'un objet en vente spécifique.
    POST /api/v1/items : Crée un nouvel objet en vente.
    PUT /api/v1/items/ : Met à jour un objet en vente existant.
    DELETE /api/v1/items/ : Supprime un objet en vente.

### Contrôleur `BidsController`

**Fichier** : `app/controllers/api/v1/bids_controller.rb`

**Rôle** : Gère les requêtes API pour les enchères.

```ruby
module Api
  module V1
    class BidsController < ApplicationController
      before_action :set_bid, only: [:show, :update, :destroy]

      # GET /api/v1/bids
      def index
        @bids = Bid.all
        render json: @bids
      end

      # GET /api/v1/bids/:id
      def show
        render json: @bid
      end

      # POST /api/v1/bids
      def create
        @bid = Bid.new(bid_params)
        if @bid.save
          render json: @bid, status: :created
        else
          render json: @bid.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/bids/:id
      def update
        if @bid.update(bid_params)
          render json: @bid
        else
          render json: @bid.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/bids/:id
      def destroy
        @bid.destroy
        head :no_content
      end

      private

      def set_bid
        @bid = Bid.find(params[:id])
      end

      def bid_params
        params.require(:bid).permit(:item_id, :user_id, :bid_amount)
      end
    end
  end
end
```
**Explication** :

    GET /api/v1/bids : Récupère la liste de toutes les enchères.
    GET /api/v1/bids/ : Récupère les détails d'une enchère spécifique.
    POST /api/v1/bids : Crée une nouvelle enchère.
    PUT /api/v1/bids/ : Met à jour une enchère existante.
    DELETE /api/v1/bids/ : Supprime une enchère.

### Contrôleur `TransactionsController`

**Fichier** : `app/controllers/api/v1/transactions_controller.rb`

**Rôle** : Gère les requêtes API pour les transactions.

```ruby
module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_transaction, only: [:show, :update, :destroy]

      # GET /api/v1/transactions
      def index
        @transactions = Transaction.all
        render json: @transactions
      end

      # GET /api/v1/transactions/:id
      def show
        render json: @transaction
      end

      # POST /api/v1/transactions
      def create
        @transaction = Transaction.new(transaction_params)
        if @transaction.save
          render json: @transaction, status: :created
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/transactions/:id
      def update
        if @transaction.update(transaction_params)
          render json: @transaction
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/transactions/:id
      def destroy
        @transaction.destroy
        head :no_content
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:item_id, :buyer_id, :seller_id, :final_price, :payment_status, :delivery_status)
      end
    end
  end
end
```
**Explication** :

    GET /api/v1/transactions : Récupère la liste de toutes les transactions.
    GET /api/v1/transactions/ : Récupère les détails d'une transaction spécifique.
    POST /api/v1/transactions : Crée une nouvelle transaction.
    PUT /api/v1/transactions/ : Met à jour une transaction existante.
    DELETE /api/v1/transactions/ : Supprime une transaction.

## Routes

**Fichier** : `config/routes.rb`

**Rôle** : Définit les routes de l'application, y compris les routes API.

```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :items, only: [:index, :show, :create, :update, :destroy]
      resources :bids, only: [:index, :show, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
```

## Sécurité et Authentification

### Utilisation de Devise

L'authentification permet de vérifier l'identité des utilisateurs. Vous pouvez utiliser des gemmes comme devise ou pour implémenter un système d'authentification sécurisé.
**Fichier** : `config/initializers/devise.rb`

**Rôle** : Configure Devise pour la gestion de l'authentification des utilisateurs.

```ruby
Devise.setup do |config|
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
  config.mailer = 'Devise::Mailer'
  config.parent_mailer = 'ActionMailer::Base'
  config.authentication_keys = [:email]
  config.reset_password_keys = [:email]
  config.confirm_within = 3.days
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.timeout_in = 30.minutes
end
```

### Utilisation de Pundit

L'autorisation permet de gérer les rôles et les permissions pour assurer que seuls les utilisateurs autorisés peuvent accéder à certaines fonctionnalités.
Pundit est une gemme populaire pour l'autorisation dans Rails.

**Fichier** : `app/policies/item_policy.rb`

**Rôle** : Définit les politiques d'autorisation pour les objets.

```ruby
class ItemPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (user == record.user || user.admin?)
  end

  def destroy?
    user.present? && (user == record.user || user.admin?)
  end
end
```

## Gestion des Transactions

Pour implémenter la gestion des transactions dans notre projet, nous avons opter pour les services de paiement comme Stripe et implémenter des fonctionnalités pour suivre l'état des transactions.

### Intégration de Stripe

**Fichier** : `config/initializers/stripe.rb`

**Rôle** : Configure Stripe pour la gestion des paiements.

```ruby
Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
```

**Fichier** : `app/controllers/payments_controller.rb`

**Rôle** : Gère les requêtes API pour les paiements.

```ruby
class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def create
    token = params[:stripeToken]
    amount = params[:amount].to_i * 100 # Convertir en cents

    begin
      customer = Stripe::Customer.create(
        email: current_user.email,
        source: token
      )

      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: 'Achat d\'objet',
        currency: 'usd'
      )

      if charge.paid
        @transaction = Transaction.create(
          item_id: params[:item_id],
          buyer_id: current_user.id,
          seller_id: Item.find(params[:item_id]).user_id,
          final_price: amount / 100.0,
          payment_status: 'completed',
          delivery_status: 'pending'
        )
        render json: { message: 'Paiement réussi', transaction: @transaction }, status: :ok
      else
        render json: { message: 'Paiement échoué' }, status: :unprocessable_entity
      end
    rescue Stripe::CardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end
end
```

## Gestion des Notifications

### Envoi de Notifications par E-mail

**Fichier** : `app/mailers/notification_mailer.rb`

**Rôle** : Définit les méthodes pour envoyer des e-mails de notification.

```ruby
class NotificationMailer < ApplicationMailer
  default from: 'notifications@yourdomain.com'

  def new_bid_email(user, item, bid)
    @user = user
    @item = item
    @bid = bid
    mail(to: @user.email, subject: 'New Bid on Your Item')
  end

  def auction_ended_email(user, item)
    @user = user
    @item = item
    mail(to: @user.email, subject: 'Auction Ended')
  end

  def sale_finalized_email(user, transaction)
    @user = user
    @transaction = transaction
    mail(to: @user.email, subject: 'Sale Finalized')
  end
end
```

**Fichier** : `app/views/notification_mailer/new_bid_email.html.erb`

**Rôle** : Définit la vue pour l'e-mail de nouvelle enchère.

```erb
<h1>New Bid on Your Item</h1>
<p>Hello <%= @user.username %>,</p>
<p>A new bid has been placed on your item "<%= @item.title %>".</p>
<p>Bid Amount: <%= @bid.bid_amount %></p>
<p>Thank you!</p>
```

### Notifications In-App avec WebSockets

**Fichier** : `app/channels/notifications_channel.rb`

**Rôle** : Définit le canal pour les notifications en temps réel.

```ruby
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
```

**Fichier** : `app/javascript/channels/notifications_channel.js`

**Rôle** : Définit le canal JavaScript pour les notifications en temps réel.

```javascript
import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    alert(data['message']);
  }
});
```

## Contribution

Les contributions sont les bienvenues ! Pour contribuer, veuillez suivre ces étapes :

1. Forker le dépôt.
2. Créer une nouvelle branche (`git checkout -b feature-branch`).
3. Commiter vos modifications (`git commit -am 'Ajouter une nouvelle fonctionnalité'`).
4. Pousser la branche (`git push origin feature-branch`).
5. Créer une nouvelle Pull Request.

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.
```

Ce fichier `README.md` fournit une vue d'ensemble complète du projet, des instructions d'installation, des informations sur les API, et des explications sur les différents fichiers et dossiers. Il est destiné à aider toute l'équipe à comprendre le projet.

## NB
   Le coté Backend est toujours en cours d'implementation notament sur la sécurité des données auquel nous allons opté pour le Chiffrement des données sensible et la validation des entrées qui vont nous prévenir des injection SQL et autres attaques.
   Ensuite nous allons implémenté le Panneau Administratif auquel nous allons utilisé ActiveAdmin qui est une gemme populaire pour la création des interfaces administratif.
   Maintenant nous allons passé au coté des Test unitaire et d'Integration qui nous permettent de vérifié si chaque composant de notre application fonctionne correctement et qu'il interagissent correctement entre eux. Nous allons utiliser la gemme RSpec qui est une gemme pour les test unitaire et d'intégration.
   Et enfin nous allons passé au Debogage