// src/main.js
import App from './App.svelte';
import { NotificationsProvider } from 'svelte-notifications';

const app = new App({
  target: document.body,
  props: {
    // You can pass props if needed
  },
  context: new Map([
    ['notifications', NotificationsProvider],
  ])
});

export default app;
