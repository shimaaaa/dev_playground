import { BookList } from "./Books"
import { Amplify } from 'aws-amplify';
import { Authenticator } from '@aws-amplify/ui-react';

import '@aws-amplify/ui-react/styles.css';
import awsconfig from './aws-exports.ts';

Amplify.configure(awsconfig);


function App() {

  console.log();
  return (
    <>
      <Authenticator>
        {({ signOut, user }) => (
          <div>
            <h1>Hello {user?.username}</h1>
            <BookList />
            <button onClick={signOut}>Sign out</button>
          </div>
        )}
      </Authenticator>
    </>
  )
}

export default App
