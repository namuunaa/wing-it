# Tonite

Tonite is an event recommendation app that allows users to use Alexa to find an
event going on today for a spontaneous outing.

## Basic Use

Add the skill Tonite to your Alexa account.

_have some instructions here for the voice commands (we are planning to update
those today)_

## Installing / Getting Started

### Alexa Skill Setup

[See Getting Started with the Alexa Skills Kit](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/getting-started-guide)

### Server Setup

```
git clone https://github.com/namuunaa/tonite.git
bundle
bin/rails db:create
rails server
```

### Connecting the Skill and Server

In the Alexa Skill configuration menu paste the location of your server in the
endpoint field. It should be something like `https://your-domain-here/alexa_interface`.

## Tech Stack

 * Ruby on Rails
 * Amazon Alexa Skill
 * Echo Dot

## User Stories

[User Stories](./user_stories.md)

## Authors

* Namuun Bayaraa [GitHub](https://github.com/namuunaa)
* Ransom Byers [GitHub](https://github.com/rasnom)
* Brianna Forster [GitHub](https://github.com/b-forster)
* Dillon Arevalo [GitHub](https://github.com/dillonbarevalo)

## Contributing

If you'd like to contribute, please fork the repository and use a feature
branch. Pull requests are warmly welcome.

## Licensing

This project is licensed under [MIT license](./LICENSE)

## Helpful Resources

 * [Primer on the grammar for Alexa custom skills](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/supported-phrases-to-begin-a-conversation)
 * [JSON Interface for Custom Skills](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-referenceg)

