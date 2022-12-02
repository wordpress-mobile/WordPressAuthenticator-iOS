enum OAuthErrors {

    struct InconsistentASWebAuthenticationSessionCompletion: LocalizedError {
        let errorDescription = "ASWebAuthenticationSession authentication finished with neither a callback URL nor error"
    }
}
