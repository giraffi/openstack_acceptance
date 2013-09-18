# coding: utf-8

Feature: OpenStack Compute API
  In order to provide services on OpenStack
  As a OpnStack user
  I want to control an infrastructure with remote api

  Background: We have own OpenStack environment.
    Given I have an account which roled member of OpenStack
    And My current tenant is available

  Scenario: Verify available Nework
    Given I retrieve "Network" from API
    Then There is at least one ACTIVE router
    And It has network "ext_net"
    And It has network "int_net"

  Scenario: Verify available Images
    Given I retrieve "Image" from API
    Then There are at least one image

  Scenario: Verify computer dependencies
    Given I retrieve "Compute" from API
    Then There are at least one flavor
    Then There are at least one keypair
