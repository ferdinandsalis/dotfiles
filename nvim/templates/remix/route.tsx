import { LoaderFunction, ActionFunction } from '@remix/node'

export const loader: LoaderFunction = async ({ request }) => {
  console.log('request: ', request)

  return null
}

export default function Route() {
  return (
    <div>
      <h1>Route</h1>
    </div>
  )
}

export const action: ActionFunction = async ({ request }) => {
  console.log('request: ', request)

  return null
}
